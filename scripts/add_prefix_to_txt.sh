#! /bin/bash

set -u

print_usage() {
    echo "Usage: $0 <directory> <prefix>"
    echo "Renames every .txt file in the directory by adding the prefix to its file name."
    echo "Example: $0 ./notes old_"
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required command '$1' is not installed." >&2
        exit 1
    fi
}

if [ "$#" -ne 2 ]; then
    print_usage
    exit 1
fi

require_command basename
require_command dirname
require_command mv

TARGET_DIR="${1%/}"
PREFIX="$2"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: directory does not exist: $TARGET_DIR" >&2
    exit 1
fi

if [ -z "$PREFIX" ]; then
    echo "Error: prefix cannot be empty." >&2
    exit 1
fi

case "$PREFIX" in
    */*)
        echo "Error: prefix cannot contain '/'." >&2
        exit 1
        ;;
esac

FILES_FOUND=0
for FILE in "$TARGET_DIR"/*.txt; do
    if [ -f "$FILE" ]; then
        FILES_FOUND=1
        BASENAME="$(basename "$FILE")"
        DESTINATION="$(dirname "$FILE")/$PREFIX$BASENAME"

        if [ -e "$DESTINATION" ]; then
            echo "Error: destination already exists: $DESTINATION" >&2
            echo "No files were renamed." >&2
            exit 1
        fi
    fi
done

if [ "$FILES_FOUND" -eq 0 ]; then
    echo "No .txt files found in: $TARGET_DIR"
    exit 0
fi

RENAMED_COUNT=0
for FILE in "$TARGET_DIR"/*.txt; do
    if [ -f "$FILE" ]; then
        BASENAME="$(basename "$FILE")"
        DESTINATION="$(dirname "$FILE")/$PREFIX$BASENAME"

        mv "$FILE" "$DESTINATION" || exit 1
        echo "Renamed: $FILE -> $DESTINATION"
        RENAMED_COUNT=$((RENAMED_COUNT + 1))
    fi
done

echo "Completed. Renamed $RENAMED_COUNT .txt file(s)."
