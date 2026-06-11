#! /bin/bash

set -u

print_usage() {
    echo "Usage: $0 <directory> <days> [--apply]"
    echo "Finds files older than the selected number of days."
    echo "Default mode is dry-run. Add --apply to delete matching files."
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required command '$1' is not installed." >&2
        exit 1
    fi
}

is_non_negative_integer() {
    case "$1" in
        ''|*[!0-9]*) return 1 ;;
        *) return 0 ;;
    esac
}

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    print_usage
    exit 1
fi

require_command find
require_command mktemp
require_command rm

TARGET_DIR="${1%/}"
DAYS="$2"
MODE="${3:-}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: directory does not exist: $TARGET_DIR" >&2
    exit 1
fi

if ! is_non_negative_integer "$DAYS"; then
    echo "Error: days must be a non-negative integer." >&2
    exit 1
fi

if [ -n "$MODE" ] && [ "$MODE" != "--apply" ]; then
    print_usage
    exit 1
fi

MATCHES_FILE="$(mktemp "${TMPDIR:-/tmp}/delete_old_files.XXXXXX")"

find "$TARGET_DIR" -type f -mtime +"$DAYS" -print > "$MATCHES_FILE"

if [ ! -s "$MATCHES_FILE" ]; then
    echo "No files older than $DAYS day(s) found in: $TARGET_DIR"
    rm -f "$MATCHES_FILE"
    exit 0
fi

echo "Files older than $DAYS day(s):"
cat "$MATCHES_FILE"

if [ "$MODE" != "--apply" ]; then
    echo
    echo "Dry-run only. To delete these files, run:"
    echo "$0 \"$TARGET_DIR\" \"$DAYS\" --apply"
    rm -f "$MATCHES_FILE"
    exit 0
fi

echo
echo "Deleting listed files..."

DELETED_COUNT=0
while IFS= read -r FILE; do
    if [ -f "$FILE" ]; then
        rm -f "$FILE" || exit 1
        echo "Deleted: $FILE"
        DELETED_COUNT=$((DELETED_COUNT + 1))
    fi
done < "$MATCHES_FILE"

rm -f "$MATCHES_FILE"
echo "Completed. Deleted $DELETED_COUNT file(s)."
