#! /bin/bash

set -u

print_usage() {
    echo "Usage: $0 <directory>"
    echo "Shows disk usage for the selected directory and each direct subdirectory."
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required command '$1' is not installed." >&2
        exit 1
    fi
}

if [ "$#" -ne 1 ]; then
    print_usage
    exit 1
fi

require_command du
require_command basename
require_command awk

TARGET_DIR="${1%/}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: directory does not exist: $TARGET_DIR" >&2
    exit 1
fi

echo "Disk usage for: $TARGET_DIR"
echo

printf "%-45s %12s\n" "Directory" "Size"
printf "%-45s %12s\n" "---------" "----"

TOTAL_SIZE="$(du -sh "$TARGET_DIR" 2>/dev/null | awk '{print $1}')"
printf "%-45s %12s\n" "." "$TOTAL_SIZE"

SUBDIRS_FOUND=0
for ITEM in "$TARGET_DIR"/* "$TARGET_DIR"/.[!.]* "$TARGET_DIR"/..?*; do
    if [ -d "$ITEM" ]; then
        SUBDIRS_FOUND=1
        SIZE="$(du -sh "$ITEM" 2>/dev/null | awk '{print $1}')"
        printf "%-45s %12s\n" "$(basename "$ITEM")" "$SIZE"
    fi
done

if [ "$SUBDIRS_FOUND" -eq 0 ]; then
    echo
    echo "No direct subdirectories found."
fi
