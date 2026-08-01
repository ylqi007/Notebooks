#!/usr/bin/env bash
set -euo pipefail

# Delete source files that already have the same relative path in destination.
# This is useful after a move/copy was interrupted and you want to clear only
# source-side files whose destination-side path already exists.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
LOG_DIR="${FILE_MOVE_LOG_DIR:-${SCRIPT_DIR}/logs}"
RUN_ID="$(date +%Y%m%d-%H%M%S)"
SOURCE=""
DESTINATION=""
PLAN_LOG=""
RUN_LOG=""
CLEANUP_LOG=""

usage() {
  cat <<'USAGE'
delete_source_files_existing_in_destination.sh - clean source after verifying destination paths exist

Usage:
  delete_source_files_existing_in_destination.sh SOURCE DESTINATION
  delete_source_files_existing_in_destination.sh --cleanup-empty SOURCE
  delete_source_files_existing_in_destination.sh --examples
  delete_source_files_existing_in_destination.sh --help

When to use:
  Use this after a transfer was interrupted or partially completed.
  It scans SOURCE. If a file also exists at the same relative path in DESTINATION,
  it can delete the SOURCE copy after a dry-run and YES confirmation.

Important:
  - This script checks path existence, not file equality.
  - If SOURCE/a/b.mp4 exists and DESTINATION/a/b.mp4 exists, SOURCE/a/b.mp4 is
    considered removable.
  - If you need byte-for-byte duplicate checking, use merge_folders.sh and choose
    DELETE_DUPLICATES at its prompt.

Safety:
  - First pass is a dry-run plan; no files are changed.
  - You must type YES before deletion starts.
  - Files missing from DESTINATION are kept in SOURCE.
  - If DESTINATION has a directory where SOURCE has a file, SOURCE is kept.
  - Empty SOURCE directories are cleaned up after deletion.
  - By default, logs are written next to this script under ./logs.
  - Override with FILE_MOVE_LOG_DIR=/path/to/logs.
USAGE
}

examples() {
  cat <<'EXAMPLES'
Examples:
  # Clean a partially transferred folder.
  ./delete_source_files_existing_in_destination.sh \
    "/Volumes/SourceDrive/FolderName" \
    "/Volumes/DestinationDrive/FolderName"

  # Clean a local folder after copying it to an external drive.
  ./delete_source_files_existing_in_destination.sh \
    "${HOME}/path/to/FolderName" \
    "/Volumes/DestinationDrive/FolderName"

  # Only remove empty directories and metadata-only directories from SOURCE.
  ./delete_source_files_existing_in_destination.sh --cleanup-empty \
    "/Volumes/SourceDrive/FolderName"

Prompts:
  - Read the dry-run summary first.
  - Type YES only when you are sure destination paths are enough proof.
EXAMPLES
}

safe_name() {
  local value="$1"

  value="${value#/}"
  value="${value//\//-}"
  value="${value// /_}"
  value="${value//[^A-Za-z0-9._-]/_}"
  printf '%s' "${value:-root}"
}

set_log_paths() {
  local prefix

  prefix="$(safe_name "${SOURCE}")-to-$(safe_name "${DESTINATION:-cleanup}")"
  PLAN_LOG="${LOG_DIR}/${prefix}-delete-existing-plan-${RUN_ID}.log"
  RUN_LOG="${LOG_DIR}/${prefix}-delete-existing-run-${RUN_ID}.log"
  CLEANUP_LOG="${LOG_DIR}/${prefix}-empty-dir-cleanup-${RUN_ID}.log"
}

cleanup_empty_dirs() {
  local log_file="$1"
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
    done < <(find "${dir}" -type f \( -name ".DS_Store" -o -name "._*" \) -print0 2>/dev/null)
  done < <(find "${SOURCE}" -depth -type d -print0 2>/dev/null)

  before="$(find "${SOURCE}" -depth -type d -empty -print 2>/dev/null | wc -l | tr -d ' ')"
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
    done < <(find "${SOURCE}" -depth -type d -empty -print0 2>/dev/null)

    current_empty="$(find "${SOURCE}" -depth -type d -empty -print 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "${current_empty}" -eq 0 || "${round_deleted}" -eq 0 ]]; then
      break
    fi
  done

  after="$(find "${SOURCE}" -depth -type d -empty -print 2>/dev/null | wc -l | tr -d ' ')"
  echo "Empty directory cleanup deleted ${deleted}, failed ${failed}, remaining ${after}."
  echo "Cleanup log: ${log_file}"
  printf 'Deleted metadata: %s\nDeleted dirs: %s\nFailed: %s\nRemaining dirs: %s\n' "${metadata_deleted}" "${deleted}" "${failed}" "${after}" >> "${log_file}"
}

scan_or_delete() {
  local mode="$1"
  local log_file="$2"
  local file
  local rel
  local dest_file
  local checked=0
  local matched=0
  local missing=0
  local deleted=0
  local failed=0
  local status

  : > "${log_file}"

  while IFS= read -r -d '' file; do
    checked=$((checked + 1))
    rel="${file#${SOURCE}/}"
    dest_file="${DESTINATION}/${rel}"

    if [[ -e "${dest_file}" && ! -d "${dest_file}" ]]; then
      matched=$((matched + 1))

      if [[ "${mode}" == "plan" ]]; then
        printf 'WOULD_DELETE: %s\nDEST_EXISTS:  %s\n\n' "${file}" "${dest_file}" >> "${log_file}"
      else
        set +e
        rm -f "${file}"
        status=$?
        set -e

        if [[ "${status}" -eq 0 ]]; then
          deleted=$((deleted + 1))
          printf 'DELETED: %s\nDEST_EXISTS: %s\n\n' "${file}" "${dest_file}" >> "${log_file}"
        else
          failed=$((failed + 1))
          printf 'FAILED_DELETE status=%s: %s\nDEST_EXISTS: %s\n\n' "${status}" "${file}" "${dest_file}" >> "${log_file}"
        fi
      fi
    else
      missing=$((missing + 1))
    fi

    if (( checked % 1000 == 0 )); then
      echo "Checked ${checked}; destination exists ${matched}; destination missing/conflict ${missing}; deleted ${deleted}; failed ${failed}"
    fi
  done < <(find "${SOURCE}" -type f -print0)

  echo
  echo "${mode} summary: checked ${checked}, destination exists ${matched}, destination missing/conflict ${missing}, deleted ${deleted}, failed ${failed}"
  printf '%s summary: checked %s, destination exists %s, destination missing/conflict %s, deleted %s, failed %s\n' \
    "${mode}" "${checked}" "${matched}" "${missing}" "${deleted}" "${failed}" >> "${log_file}"

  if [[ "${failed}" -gt 0 ]]; then
    return 1
  fi
  return 0
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
  set_log_paths

  if [[ ! -d "${SOURCE}" ]]; then
    echo "ERROR: Source directory does not exist: ${SOURCE}" >&2
    exit 1
  fi

  cleanup_empty_dirs "${CLEANUP_LOG}"
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
set_log_paths

echo "Source:      ${SOURCE}"
echo "Destination: ${DESTINATION}"
echo

if [[ ! -d "${SOURCE}" ]]; then
  echo "ERROR: Source directory does not exist: ${SOURCE}" >&2
  exit 1
fi

if [[ ! -d "${DESTINATION}" ]]; then
  echo "ERROR: Destination directory does not exist: ${DESTINATION}" >&2
  exit 1
fi

SOURCE_REAL="$(cd "${SOURCE}" && pwd -P)"
DESTINATION_REAL="$(cd "${DESTINATION}" && pwd -P)"

case "${DESTINATION_REAL}/" in
  "${SOURCE_REAL}/"*)
    echo "ERROR: Destination is inside source. Refusing to continue." >&2
    exit 1
    ;;
esac

case "${SOURCE_REAL}/" in
  "${DESTINATION_REAL}/"*)
    echo "ERROR: Source is inside destination. Refusing to continue." >&2
    exit 1
    ;;
esac

echo "Step 1: dry-run scan. No files will be deleted yet."
echo "Plan log: ${PLAN_LOG}"
echo

scan_or_delete "plan" "${PLAN_LOG}"

echo
echo "Rules:"
echo "  - If a source file has the same relative path in destination, delete the source file."
echo "  - This checks path existence, not byte-for-byte equality."
echo "  - If destination is missing that relative path, keep the source file."
echo "  - If destination has a directory where source has a file, keep the source file."
echo "  - After deletion, delete only truly empty source directories."
echo
read -r -p "Type YES to delete matching source files: " CONFIRM

if [[ "${CONFIRM}" != "YES" ]]; then
  echo "Cancelled. No files were deleted."
  exit 0
fi

echo
echo "Step 2: deleting source files that already exist in destination."
echo "Run log: ${RUN_LOG}"
echo

set +e
scan_or_delete "delete" "${RUN_LOG}"
RUN_STATUS=$?
set -e

if [[ "${RUN_STATUS}" -ne 0 ]]; then
  echo "WARNING: Some matching source files could not be deleted. Review: ${RUN_LOG}"
fi

echo
echo "Step 3: deleting empty directories left in source."
echo "Only truly empty directories are deleted; directories containing files are kept."
echo

cleanup_empty_dirs "${CLEANUP_LOG}"

echo
echo "Done."
