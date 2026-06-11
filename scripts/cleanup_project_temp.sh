#! /bin/bash

set -u

print_usage() {
    echo "Usage: $0 <project_directory> [--apply]"
    echo "Finds temporary project files and folders."
    echo "Default mode is dry-run. Add --apply to delete matches."
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

require_command find
require_command mktemp
require_command rm

PROJECT_DIR="${1%/}"
MODE="${2:-}"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: project directory does not exist: $PROJECT_DIR" >&2
    exit 1
fi

if [ -n "$MODE" ] && [ "$MODE" != "--apply" ]; then
    print_usage
    exit 1
fi

echo "Scanning temporary files in: $PROJECT_DIR"

MATCHES_FILE="$(mktemp "${TMPDIR:-/tmp}/cleanup_project_temp.XXXXXX")"

find "$PROJECT_DIR" \
    \( -type d \( -name "node_modules" \
    -o -name "__pycache__" \
    -o -name ".pytest_cache" \
    -o -name ".next" \
    -o -name "dist" \
    -o -name "build" \) -print -prune \) \
    -o \( -type f \( -name ".DS_Store" \
    -o -name "*.pyc" \
    -o -name "*.class" \
    -o -name "*.log" \) -print \) > "$MATCHES_FILE"

if [ ! -s "$MATCHES_FILE" ]; then
    echo "No temporary files or folders found."
    rm -f "$MATCHES_FILE"
    exit 0
fi

echo "Found temporary items:"
cat "$MATCHES_FILE"

if [ "$MODE" != "--apply" ]; then
    echo
    echo "Dry-run only. To delete these items, run:"
    echo "$0 \"$PROJECT_DIR\" --apply"
    rm -f "$MATCHES_FILE"
    exit 0
fi

echo
echo "Deleting listed items..."

while IFS= read -r ITEM; do
    if [ -e "$ITEM" ]; then
        rm -rf "$ITEM"
        echo "Deleted: $ITEM"
    fi
done < "$MATCHES_FILE"

rm -f "$MATCHES_FILE"
echo "Cleanup completed."
