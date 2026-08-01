#!/usr/bin/env bash
set -euo pipefail

# move_files.sh
#
# Safe folder-content mover for macOS external drives.
# It copies only files missing from DESTINATION, deletes each SOURCE file only
# after the destination file exists, keeps skipped/failed files in SOURCE, and
# cleans empty SOURCE directories at the end.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
LOG_DIR="${FILE_MOVE_LOG_DIR:-${SCRIPT_DIR}/logs}"
RUN_ID="$(date +%Y%m%d-%H%M%S)"

usage() {
  cat <<'USAGE'
move_files.sh - safe folder-content mover

What it does:
  Move the contents of SOURCE into DESTINATION without overwriting existing
  destination files. It is meant for SSD/HDD cleanup and large folder moves.

Safety rules:
  - If DESTINATION is missing a file, copy it there.
  - Delete the SOURCE file only after the destination file exists.
  - If DESTINATION already has the same relative path, keep SOURCE unchanged.
  - If a file fails to copy, keep it in SOURCE.
  - After moving, delete empty SOURCE directories.
  - Directories containing only .DS_Store or ._* metadata are treated as empty.

Usage:
  move_files.sh SOURCE DESTINATION
  move_files.sh --cleanup-empty SOURCE
  move_files.sh --examples
  move_files.sh --help

Important:
  SOURCE is the folder whose contents are moved.
  DESTINATION is the exact target folder.

To move a whole folder named SOURCE_FOLDER into a drive root, include the folder name:
  move_files.sh "/path/to/SOURCE_FOLDER" "/Volumes/ExternalDrive/SOURCE_FOLDER"

Do not do this unless you want SOURCE_FOLDER's contents directly in the drive root:
  move_files.sh "/path/to/SOURCE_FOLDER" "/Volumes/ExternalDrive"

Logs:
  By default, logs are written next to this script under ./logs.
  Override with FILE_MOVE_LOG_DIR=/path/to/logs.
USAGE
}

examples() {
  cat <<'EXAMPLES'
Examples:

Move a folder's contents into a matching folder on another drive:
  ./move_files.sh \
    "/Volumes/SourceDrive/FolderName" \
    "/Volumes/DestinationDrive/FolderName"

Move a local folder into an external drive as /Volumes/ExternalDrive/FolderName:
  ./move_files.sh \
    "${HOME}/path/to/FolderName" \
    "/Volumes/ExternalDrive/FolderName"

Keep Mac awake while moving:
  caffeinate -dimsu ./move_files.sh \
    "/Volumes/SourceDrive/FolderName" \
    "/Volumes/DestinationDrive/FolderName"

Only clean empty source directories:
  ./move_files.sh \
    --cleanup-empty "/Volumes/SourceDrive/FolderName"

Workflow:
  1. Run the command.
  2. Read the dry-run summary.
  3. Type YES only if it looks right.
  4. Check logs if any files failed.
EXAMPLES
}

safe_name() {
  local value="$1"
  basename "${value}" | tr -c '[:alnum:]_.-' '_'
}

cleanup_empty_dirs() {
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

  : > "${log_file}"

  echo "Removing Finder metadata from directory trees that contain no regular user files..."
  printf 'Removing Finder metadata from directory trees that contain no regular user files...\n' >> "${log_file}"

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
    done < <(LC_ALL=en_US.UTF-8 find "${dir}" -type f \( -name ".DS_Store" -o -name "._*" \) -print0 2>/dev/null)
  done < <(LC_ALL=en_US.UTF-8 find "${source_dir}" -depth -type d -print0 2>/dev/null)

  before="$(LC_ALL=en_US.UTF-8 find "${source_dir}" -depth -type d -empty -print 2>/dev/null | wc -l | tr -d ' ')"
  echo "Empty directories before cleanup: ${before}"
  echo "Finder metadata files deleted before cleanup: ${metadata_deleted}"
  printf 'Empty directories before cleanup: %s\n' "${before}" >> "${log_file}"
  printf 'Finder metadata files deleted before cleanup: %s\n' "${metadata_deleted}" >> "${log_file}"

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
    done < <(LC_ALL=en_US.UTF-8 find "${source_dir}" -depth -type d -empty -print0 2>/dev/null)

    current_empty="$(LC_ALL=en_US.UTF-8 find "${source_dir}" -depth -type d -empty -print 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "${current_empty}" -eq 0 || "${round_deleted}" -eq 0 ]]; then
      break
    fi
  done

  after="$(LC_ALL=en_US.UTF-8 find "${source_dir}" -depth -type d -empty -print 2>/dev/null | wc -l | tr -d ' ')"
  echo "Empty directory cleanup deleted ${deleted}, failed ${failed}, remaining ${after}."
  echo "Cleanup log: ${log_file}"
  printf 'Deleted metadata: %s\nDeleted dirs: %s\nFailed: %s\nRemaining dirs: %s\n' "${metadata_deleted}" "${deleted}" "${failed}" "${after}" >> "${log_file}"
}

run_file_by_file() {
  local mode="$1"
  local source_dir="$2"
  local destination_dir="$3"
  local log_file="$4"
  local status=0
  local file
  local rel
  local dest_file
  local dest_dir
  local file_status
  local copied=0
  local skipped=0
  local failed=0
  local seen=0

  : > "${log_file}"

  while IFS= read -r -d '' file; do
    rel="${file#${source_dir}/}"

    case "$(basename "${file}")" in
      ".DS_Store"|._*)
        continue
        ;;
    esac

    dest_file="${destination_dir}/${rel}"
    dest_dir="$(dirname "${dest_file}")"
    seen=$((seen + 1))

    if [[ -e "${dest_file}" ]]; then
      skipped=$((skipped + 1))
      if (( seen % 1000 == 0 )); then
        echo "Checked ${seen} files; would/copy ${copied}, skipped ${skipped}, failed ${failed}"
      fi
      continue
    fi

    if [[ "${mode}" == "dry-run" ]]; then
      copied=$((copied + 1))
      printf 'WOULD_COPY: %s\nTO: %s\n\n' "${file}" "${dest_file}" >> "${log_file}"
      if (( seen % 1000 == 0 )); then
        echo "Checked ${seen} files; would/copy ${copied}, skipped ${skipped}, failed ${failed}"
      fi
      continue
    fi

    set +e
    mkdir -p "${dest_dir}"
    file_status=$?
    set -e
    if [[ "${file_status}" -ne 0 ]]; then
      failed=$((failed + 1))
      printf 'FAILED_MKDIR status=%s: %s\nSOURCE_FILE: %s\n\n' "${file_status}" "${dest_dir}" "${file}" >> "${log_file}"
      status=1
      continue
    fi

    set +e
    rsync -a --log-file="${log_file}" "${file}" "${dest_dir}/"
    file_status=$?
    set -e

    if [[ "${file_status}" -eq 0 && -e "${dest_file}" ]]; then
      set +e
      rm -f "${file}"
      file_status=$?
      set -e
      if [[ "${file_status}" -eq 0 ]]; then
        copied=$((copied + 1))
        printf 'COPIED_AND_REMOVED_SOURCE: %s\nTO: %s\n\n' "${file}" "${dest_file}" >> "${log_file}"
      else
        failed=$((failed + 1))
        printf 'COPIED_BUT_FAILED_REMOVE_SOURCE status=%s: %s\nTO: %s\n\n' "${file_status}" "${file}" "${dest_file}" >> "${log_file}"
        status=1
      fi
    else
      failed=$((failed + 1))
      printf 'FAILED_COPY status=%s: %s\nTO: %s\n\n' "${file_status}" "${file}" "${dest_file}" >> "${log_file}"
      status=1
    fi

    if (( seen % 1000 == 0 )); then
      echo "Checked ${seen} files; copied ${copied}, skipped ${skipped}, failed ${failed}"
    fi
  done < <(find "${source_dir}" -type f -print0)

  echo
  echo "${mode} summary: checked ${seen}, would/copy ${copied}, skipped ${skipped}, failed ${failed}"
  printf '%s summary: checked %s, would/copy %s, skipped %s, failed %s\n' "${mode}" "${seen}" "${copied}" "${skipped}" "${failed}" >> "${log_file}"

  return "${status}"
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
  if [[ "${#}" -ne 2 ]]; then
    usage
    exit 1
  fi

  SOURCE="$2"
  if [[ ! -d "${SOURCE}" ]]; then
    echo "ERROR: Source directory does not exist: ${SOURCE}" >&2
    exit 1
  fi

  PREFIX="$(safe_name "${SOURCE}")"
  CLEANUP_LOG="${LOG_DIR}/${PREFIX}-move-empty-dir-cleanup-${RUN_ID}.log"
  cleanup_empty_dirs "${SOURCE}" "${CLEANUP_LOG}"
  echo
  echo "Done."
  exit 0
fi

if [[ "${#}" -ne 2 ]]; then
  usage
  exit 1
fi

SOURCE="$1"
DESTINATION="$2"
PREFIX="$(safe_name "${SOURCE}")-to-$(safe_name "${DESTINATION}")"
DRY_RUN_LOG="${LOG_DIR}/${PREFIX}-move-dry-run-${RUN_ID}.log"
REAL_RUN_LOG="${LOG_DIR}/${PREFIX}-move-real-run-${RUN_ID}.log"
ERROR_SUMMARY="${LOG_DIR}/${PREFIX}-move-errors-${RUN_ID}.txt"
CLEANUP_LOG="${LOG_DIR}/${PREFIX}-move-empty-dir-cleanup-${RUN_ID}.log"

echo "Source:      ${SOURCE}"
echo "Destination: ${DESTINATION}"
echo

if [[ ! -d "${SOURCE}" ]]; then
  echo "ERROR: Source directory does not exist: ${SOURCE}" >&2
  exit 1
fi

if [[ ! -d "$(dirname "${DESTINATION}")" ]]; then
  echo "ERROR: Destination parent does not exist: $(dirname "${DESTINATION}")" >&2
  exit 1
fi

SOURCE_REAL="$(cd "${SOURCE}" && pwd -P)"
DEST_PARENT="$(dirname "${DESTINATION}")"
DEST_BASE="$(basename "${DESTINATION}")"
mkdir -p "${DESTINATION}"
DEST_REAL="$(cd "${DEST_PARENT}" && cd "${DEST_BASE}" && pwd -P)"

case "${DEST_REAL}/" in
  "${SOURCE_REAL}/"*)
    echo "ERROR: Destination is inside source. Refusing to avoid recursive copying." >&2
    exit 1
    ;;
esac

case "${SOURCE_REAL}/" in
  "${DEST_REAL}/"*)
    echo "ERROR: Source is inside destination. Refusing to avoid moving a folder into its own target." >&2
    exit 1
    ;;
esac

echo "Step 1: dry-run preview. Nothing will be copied or deleted yet."
echo "Dry-run log: ${DRY_RUN_LOG}"
echo

DRY_RUN_STATUS=0
run_file_by_file "dry-run" "${SOURCE}" "${DESTINATION}" "${DRY_RUN_LOG}" || DRY_RUN_STATUS=$?

echo
echo "Dry-run complete with status: ${DRY_RUN_STATUS}"
if [[ "${DRY_RUN_STATUS}" -ne 0 ]]; then
  echo "WARNING: dry-run reported a non-zero status. Review the log before continuing."
  echo
fi

echo "Rules:"
echo "  - Files missing from destination will be copied."
echo "  - Files copied successfully will be deleted from source."
echo "  - Files already present at the same destination path will be skipped and kept in source."
echo "  - Failed files will remain in source."
echo
read -r -p "Type YES to perform the real move: " CONFIRM

if [[ "${CONFIRM}" != "YES" ]]; then
  echo "Cancelled. No files were moved."
  exit 0
fi

echo
echo "Step 2: moving files..."
echo "Real-run log: ${REAL_RUN_LOG}"
echo

REAL_RUN_STATUS=0
run_file_by_file "move" "${SOURCE}" "${DESTINATION}" "${REAL_RUN_LOG}" || REAL_RUN_STATUS=$?

echo
echo "Move completed with status: ${REAL_RUN_STATUS}"
if [[ "${REAL_RUN_STATUS}" -ne 0 ]]; then
  echo "WARNING: Some files could not be copied or removed. Review: ${REAL_RUN_LOG}"
fi

grep -Ei "error:|warning:|failed|denied|illegal byte|no such file|input/output" "${REAL_RUN_LOG}" > "${ERROR_SUMMARY}" || true
if [[ -s "${ERROR_SUMMARY}" ]]; then
  echo "Error summary: ${ERROR_SUMMARY}"
fi

echo
echo "Step 3: deleting empty directories left in source."
echo "Only truly empty directories, or directories containing only Finder metadata, are deleted."
echo

cleanup_empty_dirs "${SOURCE}" "${CLEANUP_LOG}"

echo
echo "Done."
