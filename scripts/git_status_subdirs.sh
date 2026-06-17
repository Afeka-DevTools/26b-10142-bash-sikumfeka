#! /bin/bash

set -u

print_usage() {
    echo "Usage: $0 <directory>"
    echo "Shows git status for direct subdirectories that are git repositories."
    echo "Example: $0 ."
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

require_command git
require_command basename

TARGET_DIR="$1"
if [ "$TARGET_DIR" != "/" ]; then
    TARGET_DIR="${TARGET_DIR%/}"
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: directory does not exist: $TARGET_DIR" >&2
    exit 1
fi

REPOSITORIES_FOUND=0

for ITEM in "$TARGET_DIR"/* "$TARGET_DIR"/.[!.]* "$TARGET_DIR"/..?*; do
    if [ ! -d "$ITEM" ] || [ "$(basename "$ITEM")" = ".git" ]; then
        continue
    fi

    if [ -d "$ITEM/.git" ] || [ -f "$ITEM/.git" ]; then
        REPOSITORIES_FOUND=1
        echo "========================================"
        echo "Repository: $ITEM"
        git -C "$ITEM" status --short --branch
        echo
    fi
done

if [ "$REPOSITORIES_FOUND" -eq 0 ]; then
    echo "No git repositories found in direct subdirectories of: $TARGET_DIR"
fi
