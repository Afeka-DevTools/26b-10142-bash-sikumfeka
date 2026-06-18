#! /bin/bash

set -u

print_usage() {
    echo "Usage: $0 [host]"
    echo "Checks internet connectivity and prints a timestamped log."
    echo "Default host: 8.8.8.8"
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required command '$1' is not installed." >&2
        exit 1
    fi
}

is_valid_host() {
    case "$1" in
        ''|-*|*[[:space:]]*) return 1 ;;
        *) return 0 ;;
    esac
}

if [ "$#" -gt 1 ]; then
    print_usage
    exit 1
fi

require_command ping
require_command date
require_command uname

HOST="${1:-8.8.8.8}"
COUNT=4
LINUX_TIMEOUT_SECONDS=3
MAC_TIMEOUT_MILLISECONDS=3000
OS_NAME="$(uname -s)"

if ! is_valid_host "$HOST"; then
    echo "Error: host must be a non-empty IP address or hostname without spaces and must not start with '-'." >&2
    exit 1
fi

echo "Internet connectivity check"
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Target: $HOST"
echo "Packets: $COUNT"
echo "----------------------------------------"

if [ "$OS_NAME" = "Darwin" ]; then
    PING_OUTPUT="$(ping -c "$COUNT" -W "$MAC_TIMEOUT_MILLISECONDS" "$HOST" 2>&1)"
else
    PING_OUTPUT="$(ping -c "$COUNT" -W "$LINUX_TIMEOUT_SECONDS" "$HOST" 2>&1)"
fi

PING_STATUS=$?
echo "$PING_OUTPUT"
echo "----------------------------------------"

if [ "$PING_STATUS" -eq 0 ]; then
    echo "Status: ONLINE"
    exit 0
else
    echo "Status: OFFLINE or host is unreachable"
    exit 1
fi
