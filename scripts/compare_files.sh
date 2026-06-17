#! /bin/bash

set -u

print_usage() {
    echo "Usage: $0 <file1> <file2>"
    echo "Compares two files and prints whether they are identical."
    echo "Example: $0 ./old.txt ./new.txt"
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

require_command cmp
require_command diff
require_command wc
require_command awk

FILE_ONE="$1"
FILE_TWO="$2"

for FILE in "$FILE_ONE" "$FILE_TWO"; do
    if [ ! -e "$FILE" ]; then
        echo "Error: file does not exist: $FILE" >&2
        exit 1
    fi

    if [ ! -f "$FILE" ]; then
        echo "Error: path is not a regular file: $FILE" >&2
        exit 1
    fi

    if [ ! -r "$FILE" ]; then
        echo "Error: file is not readable: $FILE" >&2
        exit 1
    fi
done

SIZE_ONE="$(wc -c < "$FILE_ONE" | awk '{print $1}')"
SIZE_TWO="$(wc -c < "$FILE_TWO" | awk '{print $1}')"

echo "File 1: $FILE_ONE ($SIZE_ONE bytes)"
echo "File 2: $FILE_TWO ($SIZE_TWO bytes)"

if cmp -s "$FILE_ONE" "$FILE_TWO"; then
    echo "Result: files are identical."
    exit 0
fi

echo "Result: files are different."
echo
echo "Unified diff:"
diff -u "$FILE_ONE" "$FILE_TWO"
