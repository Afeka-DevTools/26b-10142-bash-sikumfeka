#! /bin/bash

set -u

print_usage() {
    echo "Usage: $0 <ip_or_hostname> [start_port] [end_port]"
    echo "Scans TCP ports and prints open ports."
    echo "Default range: 1 1024"
    echo "Port range must be between 1 and 65535."
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required command '$1' is not installed." >&2
        echo "macOS: nc is included by default. Linux: install netcat-openbsd or nmap-ncat." >&2
        exit 1
    fi
}

is_valid_port() {
    case "$1" in
        ''|*[!0-9]*) return 1 ;;
    esac

    if [ "${#1}" -gt 5 ]; then
        return 1
    fi

    [ "$1" -ge 1 ] && [ "$1" -le "$MAX_PORT" ]
}

is_valid_host() {
    case "$1" in
        ''|-*|*[[:space:]]*) return 1 ;;
        *) return 0 ;;
    esac
}

scan_port() {
    local host="$1"
    local port="$2"

    if [ "$OS_NAME" = "Darwin" ]; then
        nc -z -G "$SCAN_TIMEOUT_SECONDS" "$host" "$port" >/dev/null 2>&1
    else
        nc -z -w "$SCAN_TIMEOUT_SECONDS" "$host" "$port" >/dev/null 2>&1
    fi
}

scan_port_job() {
    local port="$1"

    if scan_port "$HOST" "$port"; then
        printf "%s\n" "$port" >> "$OPEN_PORTS_FILE"
    fi
}

if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
    print_usage
    exit 1
fi

require_command nc
require_command mktemp
require_command sort
require_command uname

MAX_PORT=65535
MAX_PARALLEL=64
SCAN_TIMEOUT_SECONDS=1
OS_NAME="$(uname -s)"
HOST="$1"
START_PORT="${2:-1}"
END_PORT="${3:-1024}"

if ! is_valid_host "$HOST"; then
    echo "Error: host must be a non-empty IP address or hostname without spaces and must not start with '-'." >&2
    exit 1
fi

if ! is_valid_port "$START_PORT" || ! is_valid_port "$END_PORT"; then
    echo "Error: ports must be integers between 1 and $MAX_PORT." >&2
    exit 1
fi

if [ "$START_PORT" -gt "$END_PORT" ]; then
    echo "Error: start_port must be smaller than or equal to end_port." >&2
    exit 1
fi

TOTAL_PORTS=$((END_PORT - START_PORT + 1))
WORKER_COUNT="$MAX_PARALLEL"
if [ "$TOTAL_PORTS" -lt "$MAX_PARALLEL" ]; then
    WORKER_COUNT="$TOTAL_PORTS"
fi

OPEN_PORTS_FILE="$(mktemp "${TMPDIR:-/tmp}/port_scan_open.XXXXXX")"
trap 'rm -f "$OPEN_PORTS_FILE"' EXIT HUP INT TERM

echo "Scanning TCP ports $START_PORT-$END_PORT on $HOST..."
echo "Timeout per port: ${SCAN_TIMEOUT_SECONDS}s"
echo "Parallel workers: $WORKER_COUNT"
echo "Open ports:"

ACTIVE_JOBS=0
PORT="$START_PORT"
while [ "$PORT" -le "$END_PORT" ]; do
    scan_port_job "$PORT" &
    ACTIVE_JOBS=$((ACTIVE_JOBS + 1))

    if [ "$ACTIVE_JOBS" -ge "$MAX_PARALLEL" ]; then
        wait
        ACTIVE_JOBS=0
    fi

    PORT=$((PORT + 1))
done

wait

if [ -s "$OPEN_PORTS_FILE" ]; then
    sort -n "$OPEN_PORTS_FILE" | while IFS= read -r OPEN_PORT; do
        echo "  $OPEN_PORT"
    done
else
    echo "  None found in selected range."
fi
