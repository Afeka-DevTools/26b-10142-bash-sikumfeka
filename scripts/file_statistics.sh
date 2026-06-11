#! /bin/bash

set -u

print_usage() {
    echo "Usage: $0 <directory>"
    echo "Prints line, word and character counts for every regular file in the directory."
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required command '$1' is not installed." >&2
        exit 1
    fi
}

clean_count() {
    COUNT="$1"
    echo "${COUNT//[[:space:]]/}"
}

if [ "$#" -ne 1 ]; then
    print_usage
    exit 1
fi

require_command wc
require_command basename

TARGET_DIR="${1%/}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: directory does not exist: $TARGET_DIR" >&2
    exit 1
fi

FILES_FOUND=0

printf "%-35s %10s %10s %12s\n" "File" "Lines" "Words" "Characters"
printf "%-35s %10s %10s %12s\n" "----" "-----" "-----" "----------"

for FILE in "$TARGET_DIR"/* "$TARGET_DIR"/.[!.]* "$TARGET_DIR"/..?*; do
    if [ -f "$FILE" ]; then
        FILES_FOUND=1
        LINES="$(clean_count "$(wc -l < "$FILE")")"
        WORDS="$(clean_count "$(wc -w < "$FILE")")"
        CHARACTERS="$(clean_count "$(wc -m < "$FILE")")"

        printf "%-35s %10s %10s %12s\n" "$(basename "$FILE")" "$LINES" "$WORDS" "$CHARACTERS"
    fi
done

if [ "$FILES_FOUND" -eq 0 ]; then
    echo "No regular files found in: $TARGET_DIR"
fi
