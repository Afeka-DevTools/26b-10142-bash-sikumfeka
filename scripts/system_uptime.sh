#! /bin/bash

set -u

print_usage() {
    echo "Usage: $0"
    echo "Shows system uptime in a portable format."
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required command '$1' is not installed." >&2
        exit 1
    fi
}

format_duration() {
    TOTAL_SECONDS="$1"
    DAYS=$((TOTAL_SECONDS / 86400))
    HOURS=$(((TOTAL_SECONDS % 86400) / 3600))
    MINUTES=$(((TOTAL_SECONDS % 3600) / 60))
    SECONDS=$((TOTAL_SECONDS % 60))
    printf "%d day(s), %02d:%02d:%02d" "$DAYS" "$HOURS" "$MINUTES" "$SECONDS"
}

print_raw_uptime() {
    require_command uptime
    echo "Operating system: $OS_NAME"
    echo "System uptime:"
    uptime
}

if [ "$#" -ne 0 ]; then
    print_usage
    exit 1
fi

require_command uname
require_command date
require_command awk

OS_NAME="$(uname -s)"
UPTIME_SECONDS=""

if [ "$OS_NAME" = "Linux" ] && [ -r /proc/uptime ]; then
    UPTIME_SECONDS="$(awk '{print int($1)}' /proc/uptime)"
elif [ "$OS_NAME" = "Darwin" ]; then
    require_command sysctl
    BOOT_SECONDS="$(sysctl -n kern.boottime 2>/dev/null | awk -F'[=,]' '{gsub(/ /, "", $2); print $2}')"
    CURRENT_SECONDS="$(date +%s)"

    case "$BOOT_SECONDS" in
        ''|*[!0-9]*)
            print_raw_uptime
            exit 0
            ;;
    esac

    UPTIME_SECONDS=$((CURRENT_SECONDS - BOOT_SECONDS))
else
    print_raw_uptime
    exit 0
fi

case "$UPTIME_SECONDS" in
    ''|*[!0-9]*)
        echo "Error: could not calculate system uptime." >&2
        exit 1
        ;;
esac

echo "Operating system: $OS_NAME"
echo "System uptime: $(format_duration "$UPTIME_SECONDS")"
