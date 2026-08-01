# Scripts

Reusable macOS shell scripts for moving, merging, and cleaning large folders.

These scripts are designed for external-drive cleanup where there may be many
files, interrupted transfers, and duplicate relative paths.

## Quick Choice

Use `move_files.sh` when you want to move one folder's contents into one
destination folder without overwriting existing destination files.

Use `merge_folders.sh` when you want to merge the contents of multiple source
folders into one destination folder.

Use `delete_source_files_existing_in_destination.sh` when a transfer was already
done or interrupted, and you only want to delete source files that already have
the same relative path in destination.

## Safety Model

The scripts are intentionally conservative:

- They run a dry-run or plan step first.
- They require typing `YES` before real file changes.
- Files that fail copy/verify are kept in source.
- Empty source directories are cleaned up only after file handling.
- macOS Finder metadata files such as `.DS_Store` and `._*` are treated as
  removable only when a directory tree contains no regular user files.

## Logs

By default, logs are written to:

```bash
./logs
```

relative to this `Scripts` folder.

You can override the log directory:

```bash
FILE_MOVE_LOG_DIR=/path/to/logs ./move_files.sh SOURCE DESTINATION
```

Logs may contain full file paths. Do not commit logs to a public repository.

## move_files.sh

Move the contents of one source folder into one destination folder.

```bash
./move_files.sh SOURCE DESTINATION
```

Example:

```bash
./move_files.sh \
  "/Volumes/SourceDrive/FolderName" \
  "/Volumes/DestinationDrive/FolderName"
```

To move a whole folder as a named folder under a drive root, include the final
folder name in `DESTINATION`:

```bash
./move_files.sh \
  "/path/to/FolderName" \
  "/Volumes/ExternalDrive/FolderName"
```

Clean empty source directories only:

```bash
./move_files.sh --cleanup-empty "/Volumes/SourceDrive/FolderName"
```

## merge_folders.sh

Merge the contents of one or more source folders into one destination folder.

```bash
./merge_folders.sh DESTINATION SOURCE [SOURCE ...]
```

Example:

```bash
./merge_folders.sh \
  "/Volumes/DestinationDrive/Merged" \
  "/Volumes/SourceDrive/FolderA" \
  "/Volumes/SourceDrive/FolderB"
```

If destination already has a file at the same relative path, the script can
compare byte-for-byte and delete the source duplicate only when you type
`DELETE_DUPLICATES` at the prompt. Different files are kept in source.

Clean empty source directories only:

```bash
./merge_folders.sh --cleanup-empty \
  "/Volumes/SourceDrive/FolderA" \
  "/Volumes/SourceDrive/FolderB"
```

## delete_source_files_existing_in_destination.sh

Delete source files that already have the same relative path in destination.

```bash
./delete_source_files_existing_in_destination.sh SOURCE DESTINATION
```

Example:

```bash
./delete_source_files_existing_in_destination.sh \
  "/Volumes/SourceDrive/FolderName" \
  "/Volumes/DestinationDrive/FolderName"
```

Important: this script checks path existence, not byte-for-byte equality. If
you need content comparison, use `merge_folders.sh` and choose
`DELETE_DUPLICATES`.

Clean empty source directories only:

```bash
./delete_source_files_existing_in_destination.sh --cleanup-empty \
  "/Volumes/SourceDrive/FolderName"
```

## Built-In Help

Each script has self-contained help and examples:

```bash
./move_files.sh --help
./move_files.sh --examples

./merge_folders.sh --help
./merge_folders.sh --examples

./delete_source_files_existing_in_destination.sh --help
./delete_source_files_existing_in_destination.sh --examples
```

## Keep Mac Awake

For long transfers, run through `caffeinate`:

```bash
caffeinate -dimsu ./move_files.sh \
  "/Volumes/SourceDrive/FolderName" \
  "/Volumes/DestinationDrive/FolderName"
```

