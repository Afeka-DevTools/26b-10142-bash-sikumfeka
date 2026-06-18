#! /bin/bash

set -u

print_usage() {
    echo "Usage: $0 <source_directory> [output_directory]"
    echo "Creates a tar.gz backup of source_directory."
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required command '$1' is not installed." >&2
        exit 1
    fi
}

normalize_directory_path() {
    if [ "$1" = "/" ]; then
        printf "/"
    else
        printf "%s" "${1%/}"
    fi
}

next_backup_file() {
    candidate="$1"
    if [ ! -e "$candidate" ]; then
        printf "%s" "$candidate"
        return 0
    fi

    index=1
    while [ "$index" -le 99 ]; do
        candidate="${BACKUP_BASE}_${index}.tar.gz"
        if [ ! -e "$candidate" ]; then
            printf "%s" "$candidate"
            return 0
        fi
        index=$((index + 1))
    done

    echo "Error: could not find an available backup file name." >&2
    exit 1
}

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    print_usage
    exit 1
fi

require_command tar
require_command date
require_command basename
require_command dirname
require_command mkdir

SOURCE_DIR="$(normalize_directory_path "$1")"
OUTPUT_DIR="$(normalize_directory_path "${2:-.}")"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: source directory does not exist: $SOURCE_DIR" >&2
    exit 1
fi

if [ "$SOURCE_DIR" = "/" ]; then
    echo "Error: refusing to back up the root directory." >&2
    exit 1
fi

if [ ! -r "$SOURCE_DIR" ] || [ ! -x "$SOURCE_DIR" ]; then
    echo "Error: source directory is not readable: $SOURCE_DIR" >&2
    exit 1
fi

if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Output directory does not exist. Creating: $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR" || exit 1
fi

if [ ! -w "$OUTPUT_DIR" ]; then
    echo "Error: output directory is not writable: $OUTPUT_DIR" >&2
    exit 1
fi

SOURCE_ABS="$(cd "$SOURCE_DIR" && pwd -P)" || exit 1
OUTPUT_ABS="$(cd "$OUTPUT_DIR" && pwd -P)" || exit 1

case "$OUTPUT_ABS" in
    "$SOURCE_ABS"|"$SOURCE_ABS"/*)
        echo "Error: output directory must be outside the source directory." >&2
        exit 1
        ;;
esac

SOURCE_PARENT="$(dirname "$SOURCE_ABS")"
SOURCE_NAME="$(basename "$SOURCE_ABS")"
TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
BACKUP_BASE="$OUTPUT_ABS/${SOURCE_NAME}_backup_${TIMESTAMP}"
BACKUP_FILE="$(next_backup_file "${BACKUP_BASE}.tar.gz")"

echo "Backing up '$SOURCE_DIR' to '$BACKUP_FILE'..."

if tar -czf "$BACKUP_FILE" -C "$SOURCE_PARENT" "$SOURCE_NAME"; then
    echo "Backup completed successfully."
    echo "Created file: $BACKUP_FILE"
else
    echo "Error: backup failed." >&2
    exit 1
fi
