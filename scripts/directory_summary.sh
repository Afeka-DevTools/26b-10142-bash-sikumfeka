#! /bin/bash

set -u

print_usage() {
    echo "Usage: $0 <directory>"
    echo "Counts direct files, directories, symbolic links and other entries in a directory."
    echo "Example: $0 ./scripts"
}

if [ "$#" -ne 1 ]; then
    print_usage
    exit 1
fi

TARGET_DIR="$1"
if [ "$TARGET_DIR" != "/" ]; then
    TARGET_DIR="${TARGET_DIR%/}"
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: directory does not exist: $TARGET_DIR" >&2
    exit 1
fi

FILES=0
DIRECTORIES=0
LINKS=0
OTHER=0
TOTAL=0

for ITEM in "$TARGET_DIR"/* "$TARGET_DIR"/.[!.]* "$TARGET_DIR"/..?*; do
    if [ ! -e "$ITEM" ] && [ ! -L "$ITEM" ]; then
        continue
    fi

    TOTAL=$((TOTAL + 1))

    if [ -L "$ITEM" ]; then
        LINKS=$((LINKS + 1))
    elif [ -f "$ITEM" ]; then
        FILES=$((FILES + 1))
    elif [ -d "$ITEM" ]; then
        DIRECTORIES=$((DIRECTORIES + 1))
    else
        OTHER=$((OTHER + 1))
    fi
done

echo "Directory summary for: $TARGET_DIR"
echo
printf "%-18s %8s\n" "Entry type" "Count"
printf "%-18s %8s\n" "----------" "-----"
printf "%-18s %8d\n" "Files" "$FILES"
printf "%-18s %8d\n" "Directories" "$DIRECTORIES"
printf "%-18s %8d\n" "Symbolic links" "$LINKS"
printf "%-18s %8d\n" "Other" "$OTHER"
printf "%-18s %8d\n" "Total" "$TOTAL"
