#! /bin/bash

set -u

print_usage() {
    echo "Usage: $0 <HH:MM:SS>"
    echo "Runs a countdown timer."
    echo "Example: $0 00:05:00"
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required command '$1' is not installed." >&2
        exit 1
    fi
}

format_time() {
    TOTAL_SECONDS="$1"
    HOURS=$((TOTAL_SECONDS / 3600))
    MINUTES=$(((TOTAL_SECONDS % 3600) / 60))
    SECONDS=$((TOTAL_SECONDS % 60))
    printf "%02d:%02d:%02d" "$HOURS" "$MINUTES" "$SECONDS"
}

if [ "$#" -ne 1 ]; then
    print_usage
    exit 1
fi

require_command sleep

INPUT="$1"

if ! [[ "$INPUT" =~ ^[0-9]+:[0-5][0-9]:[0-5][0-9]$ ]]; then
    echo "Error: time must be in HH:MM:SS format, with minutes and seconds between 00 and 59." >&2
    print_usage
    exit 1
fi

HOURS_PART="${INPUT%%:*}"
REST="${INPUT#*:}"
MINUTES_PART="${REST%%:*}"
SECONDS_PART="${REST#*:}"

TOTAL_SECONDS=$((10#$HOURS_PART * 3600 + 10#$MINUTES_PART * 60 + 10#$SECONDS_PART))

if [ "$TOTAL_SECONDS" -le 0 ]; then
    echo "Error: countdown time must be greater than zero." >&2
    exit 1
fi

echo "Countdown started for $(format_time "$TOTAL_SECONDS"). Press Ctrl+C to stop."

while [ "$TOTAL_SECONDS" -gt 0 ]; do
    printf "\rRemaining: %s" "$(format_time "$TOTAL_SECONDS")"
    sleep 1
    TOTAL_SECONDS=$((TOTAL_SECONDS - 1))
done

printf "\rRemaining: 00:00:00\n"
echo "Done."
