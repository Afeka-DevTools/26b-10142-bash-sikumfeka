#! /bin/bash

set -u

print_usage() {
    echo "Usage: $0 <ip_or_hostname> [start_port] [end_port]"
    echo "Scans TCP ports and prints open ports."
    echo "Default range: 1 1024"
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required command '$1' is not installed." >&2
        echo "macOS: nc is included by default. Linux: install netcat-openbsd or nmap-ncat." >&2
        exit 1
    fi
}

is_positive_integer() {
    case "$1" in
        ''|*[!0-9]*) return 1 ;;
        *) [ "$1" -gt 0 ] ;;
    esac
}

scan_port() {
    host="$1"
    port="$2"
    os_name="$(uname -s)"

    if [ "$os_name" = "Darwin" ]; then
        nc -z -G 1 "$host" "$port" >/dev/null 2>&1
    else
        nc -z -w 1 "$host" "$port" >/dev/null 2>&1
    fi
}

if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
    print_usage
    exit 1
fi

require_command nc
require_command uname

HOST="$1"
START_PORT="${2:-1}"
END_PORT="${3:-1024}"

if ! is_positive_integer "$START_PORT" || ! is_positive_integer "$END_PORT"; then
    echo "Error: ports must be positive integers." >&2
    exit 1
fi

if [ "$START_PORT" -gt "$END_PORT" ]; then
    echo "Error: start_port must be smaller than or equal to end_port." >&2
    exit 1
fi

echo "Scanning TCP ports $START_PORT-$END_PORT on $HOST..."
echo "Open ports:"

FOUND_OPEN=0
PORT="$START_PORT"
while [ "$PORT" -le "$END_PORT" ]; do
    if scan_port "$HOST" "$PORT"; then
        echo "  $PORT"
        FOUND_OPEN=1
    fi
    PORT=$((PORT + 1))
done

if [ "$FOUND_OPEN" -eq 0 ]; then
    echo "  None found in selected range."
fi
