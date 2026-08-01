#!/usr/bin/env bash
set -euo pipefail

# Merge the contents of one or more source folders into one destination folder.
# Missing files are transferred; existing relative paths are kept unless you
# explicitly choose byte-for-byte duplicate deletion during the prompt.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
LOG_DIR="${FILE_MOVE_LOG_DIR:-${SCRIPT_DIR}/logs}"
RUN_ID="$(date +%Y%m%d-%H%M%S)"
PLAN_LOG="${LOG_DIR}/merge-folders-plan-${RUN_ID}.log"
RUN_LOG="${LOG_DIR}/merge-folders-run-${RUN_ID}.log"
CLEANUP_LOG="${LOG_DIR}/merge-folders-empty-dir-cleanup-${RUN_ID}.log"

usage() {
  cat <<'USAGE'
merge_folders.sh - merge several folder CONTENTS into one destination folder

Usage:
  merge_folders.sh DESTINATION SOURCE [SOURCE ...]
  merge_folders.sh --cleanup-empty SOURCE [SOURCE ...]
  merge_folders.sh --examples
  merge_folders.sh --help

When to use:
  Use this when you have several folders that should become one folder.
  Example shape:

    DESTINATION/
      old files...

    SOURCE_A/
      video1.mp4

    SOURCE_B/
      nested/photo.jpg

  After the merge:

    DESTINATION/
      old files...
      video1.mp4
      nested/photo.jpg

Behavior:
  - Merges the contents of each SOURCE folder into DESTINATION.
  - It does not create DESTINATION/SOURCE_NAME by default; it moves each SOURCE's contents.
  - Missing files are moved with mv when SOURCE and DESTINATION are on the same volume.
  - Across volumes, files are copied, verified, then removed from SOURCE.
  - If DESTINATION already has the same relative file:
      * dry-run only records the path and avoids slow full-file comparison.
      * real run deletes the source duplicate only if you type DELETE_DUPLICATES.
      * real run keeps source files whose bytes are different.
  - Empty SOURCE directories are cleaned up after the run.
  - macOS Finder metadata files (.DS_Store and ._* files) are ignored for transfer
    and removed only when a directory tree contains no regular user files.

Safety:
  - First pass is a dry-run plan; no files are changed.
  - You must type YES before the real merge starts.
  - Existing different files are kept in SOURCE.
  - By default, logs are written next to this script under ./logs.
  - Override with FILE_MOVE_LOG_DIR=/path/to/logs.
USAGE
}

examples() {
  cat <<'EXAMPLES'
Examples:
  # Merge two folders into one destination folder.
  ./merge_folders.sh \
    "/Volumes/DestinationDrive/Merged" \
    "/Volumes/SourceDrive/FolderA" \
    "/Volumes/SourceDrive/FolderB"

  # Move a folder as a named folder under another drive.
  # The destination includes the final folder name.
  ./merge_folders.sh \
    "/Volumes/DestinationDrive/FolderName" \
    "/Volumes/SourceDrive/FolderName"

  # Clean empty source directories only.
  ./merge_folders.sh --cleanup-empty \
    "/Volumes/SourceDrive/FolderA" \
    "/Volumes/SourceDrive/FolderB"

Prompts:
  - Type DELETE_DUPLICATES only when you want identical duplicate source files deleted.
  - Type YES only after reviewing the dry-run summary.
EXAMPLES
}

cleanup_empty_dirs_for_source() {
  local source_dir="$1"
  local log_file="$2"
  local dir
  local metadata_file
  local before=0
  local deleted=0
  local metadata_deleted=0
  local failed=0
  local after=0
  local round_deleted=0
  local current_empty=0
  local status

  printf '\nSOURCE: %s\n' "${source_dir}" >> "${log_file}"

  while IFS= read -r -d '' dir; do
    if find "${dir}" -type f ! -name ".DS_Store" ! -name "._*" -print -quit 2>/dev/null | grep -q .; then
      continue
    fi

    while IFS= read -r -d '' metadata_file; do
      set +e
      rm -f "${metadata_file}"
      status=$?
      set -e

      if [[ "${status}" -eq 0 ]]; then
        metadata_deleted=$((metadata_deleted + 1))
        printf 'DELETED_METADATA: %s\n' "${metadata_file}" >> "${log_file}"
      else
        failed=$((failed + 1))
        printf 'FAILED_METADATA status=%s: %s\n' "${status}" "${metadata_file}" >> "${log_file}"
      fi
    done < <(find "${dir}" -type f \( -name ".DS_Store" -o -name "._*" \) -print0 2>/dev/null)
  done < <(find "${source_dir}" -depth -type d -print0 2>/dev/null)

  before="$(find "${source_dir}" -depth -type d -empty -print 2>/dev/null | wc -l | tr -d ' ')"

  while :; do
    round_deleted=0

    while IFS= read -r -d '' dir; do
      set +e
      rmdir "${dir}"
      status=$?
      set -e

      if [[ "${status}" -eq 0 ]]; then
        deleted=$((deleted + 1))
        round_deleted=$((round_deleted + 1))
        printf 'DELETED_DIR: %s\n' "${dir}" >> "${log_file}"
      else
        failed=$((failed + 1))
        printf 'FAILED_DIR status=%s: %s\n' "${status}" "${dir}" >> "${log_file}"
      fi
    done < <(find "${source_dir}" -depth -type d -empty -print0 2>/dev/null)

    current_empty="$(find "${source_dir}" -depth -type d -empty -print 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "${current_empty}" -eq 0 || "${round_deleted}" -eq 0 ]]; then
      break
    fi
  done

  after="$(find "${source_dir}" -depth -type d -empty -print 2>/dev/null | wc -l | tr -d ' ')"
  echo "Cleanup ${source_dir}: metadata ${metadata_deleted}, dirs ${deleted}, failed ${failed}, remaining empty dirs ${after}"
  printf 'Before empty dirs: %s\nDeleted metadata: %s\nDeleted dirs: %s\nFailed: %s\nRemaining empty dirs: %s\n' \
    "${before}" "${metadata_deleted}" "${deleted}" "${failed}" "${after}" >> "${log_file}"
}

same_file() {
  local left="$1"
  local right="$2"

  [[ -f "${left}" && -f "${right}" ]] || return 1
  [[ "$(stat -f '%z' "${left}")" == "$(stat -f '%z' "${right}")" ]] || return 1
  cmp -s "${left}" "${right}"
}

same_volume() {
  local left="$1"
  local right="$2"

  [[ "$(stat -f '%d' "${left}")" == "$(stat -f '%d' "${right}")" ]]
}

merge_source() {
  local mode="$1"
  local source_dir="$2"
  local destination_dir="$3"
  local delete_duplicates="$4"
  local log_file="$5"
  local file
  local rel
  local dest_file
  local dest_dir
  local checked=0
  local transferred=0
  local moved=0
  local copied=0
  local existing=0
  local duplicate=0
  local duplicate_deleted=0
  local conflict=0
  local failed=0
  local status
  local transfer_method="copy"

  if same_volume "${source_dir}" "${destination_dir}"; then
    transfer_method="move"
  fi

  printf '\nSOURCE: %s\nDESTINATION: %s\nMODE: %s\nTRANSFER_METHOD: %s\n' "${source_dir}" "${destination_dir}" "${mode}" "${transfer_method}" >> "${log_file}"
  echo "Source ${source_dir}: transfer method for missing files is ${transfer_method}."

  while IFS= read -r -d '' file; do
    checked=$((checked + 1))
    rel="${file#${source_dir}/}"
    dest_file="${destination_dir}/${rel}"
    dest_dir="$(dirname "${dest_file}")"

    case "$(basename "${file}")" in
      ".DS_Store"|._*)
        continue
        ;;
    esac

    if [[ -e "${dest_file}" ]]; then
      existing=$((existing + 1))

      if [[ "${mode}" == "plan" ]]; then
        printf 'DEST_EXISTS_WILL_COMPARE_ON_RUN_IF_DELETING_DUPLICATES: %s\nDEST_EXISTS: %s\n\n' "${file}" "${dest_file}" >> "${log_file}"
      elif [[ "${delete_duplicates}" != "yes" ]]; then
        printf 'DEST_EXISTS_KEEP_SOURCE: %s\nDEST_EXISTS: %s\n\n' "${file}" "${dest_file}" >> "${log_file}"
      elif same_file "${file}" "${dest_file}"; then
        duplicate=$((duplicate + 1))
        set +e
        rm -f "${file}"
        status=$?
        set -e
        if [[ "${status}" -eq 0 ]]; then
          duplicate_deleted=$((duplicate_deleted + 1))
          printf 'DELETED_DUPLICATE: %s\nDEST_EXISTS: %s\n\n' "${file}" "${dest_file}" >> "${log_file}"
        else
          failed=$((failed + 1))
          printf 'FAILED_DELETE_DUPLICATE status=%s: %s\nDEST_EXISTS: %s\n\n' "${status}" "${file}" "${dest_file}" >> "${log_file}"
        fi
      else
        conflict=$((conflict + 1))
        printf 'CONFLICT_KEEP_SOURCE: %s\nDEST_EXISTS_DIFFERENT: %s\n\n' "${file}" "${dest_file}" >> "${log_file}"
      fi
      continue
    fi

    if [[ "${mode}" == "plan" ]]; then
      transferred=$((transferred + 1))
      if [[ "${transfer_method}" == "move" ]]; then
        printf 'WOULD_MOVE_METADATA_ONLY: %s\nTO: %s\n\n' "${file}" "${dest_file}" >> "${log_file}"
      else
        printf 'WOULD_COPY_VERIFY_REMOVE_SOURCE: %s\nTO: %s\n\n' "${file}" "${dest_file}" >> "${log_file}"
      fi
      continue
    fi

    set +e
    mkdir -p "${dest_dir}"
    status=$?
    set -e
    if [[ "${status}" -ne 0 ]]; then
      failed=$((failed + 1))
      printf 'FAILED_MKDIR status=%s: %s\nSOURCE_FILE: %s\n\n' "${status}" "${dest_dir}" "${file}" >> "${log_file}"
      continue
    fi

    if [[ "${transfer_method}" == "move" ]]; then
      set +e
      mv "${file}" "${dest_file}"
      status=$?
      set -e
      if [[ "${status}" -eq 0 && -e "${dest_file}" ]]; then
        moved=$((moved + 1))
        transferred=$((transferred + 1))
        printf 'MOVED_METADATA_ONLY: %s\nTO: %s\n\n' "${file}" "${dest_file}" >> "${log_file}"
      else
        failed=$((failed + 1))
        printf 'FAILED_MOVE status=%s: %s\nTO: %s\n\n' "${status}" "${file}" "${dest_file}" >> "${log_file}"
      fi
    else
      set +e
      cp -p "${file}" "${dest_file}"
      status=$?
      set -e
      if [[ "${status}" -ne 0 ]]; then
        failed=$((failed + 1))
        printf 'FAILED_COPY status=%s: %s\nTO: %s\n\n' "${status}" "${file}" "${dest_file}" >> "${log_file}"
        continue
      fi

      if same_file "${file}" "${dest_file}"; then
        set +e
        rm -f "${file}"
        status=$?
        set -e
        if [[ "${status}" -eq 0 ]]; then
          copied=$((copied + 1))
          transferred=$((transferred + 1))
          printf 'COPIED_VERIFIED_REMOVED_SOURCE: %s\nTO: %s\n\n' "${file}" "${dest_file}" >> "${log_file}"
        else
          failed=$((failed + 1))
          printf 'COPIED_BUT_FAILED_REMOVE_SOURCE status=%s: %s\nTO: %s\n\n' "${status}" "${file}" "${dest_file}" >> "${log_file}"
        fi
      else
        failed=$((failed + 1))
        printf 'FAILED_VERIFY_AFTER_COPY: %s\nTO: %s\n\n' "${file}" "${dest_file}" >> "${log_file}"
      fi
    fi

    if (( checked % 1000 == 0 )); then
      echo "Checked ${checked} in ${source_dir}; transferred ${transferred}, destination_exists ${existing}, duplicates_deleted ${duplicate_deleted}, conflicts ${conflict}, failed ${failed}"
    fi
  done < <(find "${source_dir}" -type f -print0)

  echo "Summary for ${source_dir}: checked ${checked}, transferred ${transferred}, moved ${moved}, copied ${copied}, destination_exists ${existing}, duplicates ${duplicate}, duplicate_deleted ${duplicate_deleted}, conflicts ${conflict}, failed ${failed}"
  printf 'SUMMARY checked=%s transferred=%s moved=%s copied=%s destination_exists=%s duplicates=%s duplicate_deleted=%s conflicts=%s failed=%s\n' \
    "${checked}" "${transferred}" "${moved}" "${copied}" "${existing}" "${duplicate}" "${duplicate_deleted}" "${conflict}" "${failed}" >> "${log_file}"

  [[ "${failed}" -eq 0 ]]
}

if [[ "${1:-}" == "--help" || "${#}" -lt 1 ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" == "--examples" ]]; then
  examples
  exit 0
fi

mkdir -p "${LOG_DIR}"

if [[ "${1:-}" == "--cleanup-empty" ]]; then
  shift
  if [[ "${#}" -lt 1 ]]; then
    usage
    exit 1
  fi

  : > "${CLEANUP_LOG}"
  for source in "$@"; do
    if [[ -d "${source}" ]]; then
      cleanup_empty_dirs_for_source "${source}" "${CLEANUP_LOG}"
    else
      echo "WARNING: not a directory, skipping cleanup: ${source}" >&2
    fi
  done
  echo "Cleanup log: ${CLEANUP_LOG}"
  exit 0
fi

if [[ "${#}" -lt 2 ]]; then
  usage
  exit 1
fi

DESTINATION="$1"
shift
SOURCES=("$@")

for source in "${SOURCES[@]}"; do
  if [[ ! -d "${source}" ]]; then
    echo "ERROR: Source folder does not exist: ${source}" >&2
    exit 1
  fi
done

mkdir -p "${DESTINATION}"
DESTINATION_REAL="$(cd "${DESTINATION}" && pwd -P)"

for source in "${SOURCES[@]}"; do
  SOURCE_REAL="$(cd "${source}" && pwd -P)"
  case "${DESTINATION_REAL}/" in
    "${SOURCE_REAL}/"*)
      echo "ERROR: Destination is inside source. Refusing: ${DESTINATION} inside ${source}" >&2
      exit 1
      ;;
  esac
  case "${SOURCE_REAL}/" in
    "${DESTINATION_REAL}/"*)
      echo "ERROR: Source is inside destination. Refusing to avoid moving a folder into its own merge target: ${source}" >&2
      exit 1
      ;;
  esac
done

: > "${PLAN_LOG}"

echo "Destination: ${DESTINATION}"
echo "Sources:"
for source in "${SOURCES[@]}"; do
  echo "  ${source}"
done
echo
echo "Step 1: dry-run plan. Nothing will be copied or deleted yet."
echo "Plan log: ${PLAN_LOG}"
echo

for source in "${SOURCES[@]}"; do
  merge_source "plan" "${source}" "${DESTINATION}" "no" "${PLAN_LOG}" || true
done

echo
echo "Duplicate handling:"
echo "  - Press Enter to keep source files whose relative path already exists in destination."
echo "  - Type DELETE_DUPLICATES to compare existing files byte-for-byte and delete source only when identical."
echo "  - Byte-for-byte comparison can take a long time for large videos."
echo
read -r -p "Type DELETE_DUPLICATES to delete identical duplicate source files during merge, or press Enter to keep them: " DUP_CONFIRM

DELETE_DUPLICATES="no"
if [[ "${DUP_CONFIRM}" == "DELETE_DUPLICATES" ]]; then
  DELETE_DUPLICATES="yes"
fi

echo
read -r -p "Type YES to perform the merge: " CONFIRM

if [[ "${CONFIRM}" != "YES" ]]; then
  echo "Cancelled. No files were changed."
  exit 0
fi

: > "${RUN_LOG}"
echo
echo "Step 2: merging folders..."
echo "Run log: ${RUN_LOG}"
echo

RUN_STATUS=0
for source in "${SOURCES[@]}"; do
  merge_source "run" "${source}" "${DESTINATION}" "${DELETE_DUPLICATES}" "${RUN_LOG}" || RUN_STATUS=1
done

if [[ "${RUN_STATUS}" -ne 0 ]]; then
  echo "WARNING: Some files could not be copied or deleted. Review: ${RUN_LOG}"
fi

echo
echo "Step 3: cleaning empty source directories..."
: > "${CLEANUP_LOG}"
for source in "${SOURCES[@]}"; do
  if [[ -d "${source}" ]]; then
    cleanup_empty_dirs_for_source "${source}" "${CLEANUP_LOG}"
  fi
done

echo "Cleanup log: ${CLEANUP_LOG}"
echo
echo "Done."
