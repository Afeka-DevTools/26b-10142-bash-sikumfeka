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

normalize_directory_path() {
    if [ "$1" = "/" ]; then
        printf "/"
    else
        printf "%s" "${1%/}"
    fi
}

print_matches() {
    while IFS= read -r -d '' ITEM; do
        printf "%s\n" "$ITEM"
    done < "$MATCHES_FILE"
}

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    print_usage
    exit 1
fi

require_command find
require_command mktemp
require_command rm

PROJECT_DIR="$(normalize_directory_path "$1")"
MODE="${2:-}"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: project directory does not exist: $PROJECT_DIR" >&2
    exit 1
fi

if [ -n "$MODE" ] && [ "$MODE" != "--apply" ]; then
    print_usage
    exit 1
fi

PROJECT_ABS="$(cd "$PROJECT_DIR" && pwd -P)" || exit 1

if [ "$MODE" = "--apply" ]; then
    if [ "$PROJECT_ABS" = "/" ]; then
        echo "Error: refusing to delete temporary files from the root directory." >&2
        exit 1
    fi

    if [ -n "${HOME:-}" ] && [ "$PROJECT_ABS" = "$HOME" ]; then
        echo "Error: refusing to delete temporary files directly from HOME." >&2
        exit 1
    fi
fi

echo "Scanning temporary files in: $PROJECT_DIR"

MATCHES_FILE="$(mktemp "${TMPDIR:-/tmp}/cleanup_project_temp.XXXXXX")"
trap 'rm -f "$MATCHES_FILE"' EXIT HUP INT TERM

find "$PROJECT_DIR" \
    \( -type d \( -name ".git" \
    -o -name ".hg" \
    -o -name ".svn" \) -prune \) \
    -o \
    \( -type d \( -name "node_modules" \
    -o -name "__pycache__" \
    -o -name ".pytest_cache" \
    -o -name ".next" \
    -o -name "dist" \
    -o -name "build" \) -print0 -prune \) \
    -o \( -type f \( -name ".DS_Store" \
    -o -name "*.pyc" \
    -o -name "*.class" \
    -o -name "*.log" \) -print0 \) > "$MATCHES_FILE"

if [ ! -s "$MATCHES_FILE" ]; then
    echo "No temporary files or folders found."
    exit 0
fi

echo "Found temporary items:"
print_matches

if [ "$MODE" != "--apply" ]; then
    echo
    echo "Dry-run only. To delete these items, run:"
    echo "$0 \"$PROJECT_DIR\" --apply"
    exit 0
fi

echo
echo "Deleting listed items..."

DELETED_COUNT=0
while IFS= read -r -d '' ITEM; do
    if [ -e "$ITEM" ]; then
        if rm -rf "$ITEM"; then
            echo "Deleted: $ITEM"
            DELETED_COUNT=$((DELETED_COUNT + 1))
        else
            echo "Error: failed to delete: $ITEM" >&2
            exit 1
        fi
    fi
done < "$MATCHES_FILE"

echo "Cleanup completed. Deleted $DELETED_COUNT item(s)."
