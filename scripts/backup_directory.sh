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

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    print_usage
    exit 1
fi

require_command tar
require_command date
require_command basename
require_command dirname
require_command mkdir

SOURCE_DIR="${1%/}"
OUTPUT_DIR="${2:-.}"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: source directory does not exist: $SOURCE_DIR" >&2
    exit 1
fi

if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Output directory does not exist. Creating: $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR" || exit 1
fi

SOURCE_PARENT="$(cd "$(dirname "$SOURCE_DIR")" && pwd)"
SOURCE_NAME="$(basename "$SOURCE_DIR")"
TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
BACKUP_FILE="$OUTPUT_DIR/${SOURCE_NAME}_backup_${TIMESTAMP}.tar.gz"

echo "Backing up '$SOURCE_DIR' to '$BACKUP_FILE'..."

if tar -czf "$BACKUP_FILE" -C "$SOURCE_PARENT" "$SOURCE_NAME"; then
    echo "Backup completed successfully."
    echo "Created file: $BACKUP_FILE"
else
    echo "Error: backup failed." >&2
    exit 1
fi
