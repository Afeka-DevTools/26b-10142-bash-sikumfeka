#! /bin/bash

set -u

print_usage() {
    echo "Usage: $0 [length]"
    echo "Generates a random password. Default length: 10."
    echo "Length must be at least 4 so the password can include all required character types."
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required command '$1' is not installed." >&2
        exit 1
    fi
}

is_positive_integer() {
    case "$1" in
        ''|*[!0-9]*) return 1 ;;
        *) [ "$1" -gt 0 ] ;;
    esac
}

random_chars() {
    CHARSET="$1"
    COUNT="$2"
    LC_ALL=C tr -dc "$CHARSET" < /dev/urandom | head -c "$COUNT"
}

shuffle_password() {
    awk '
        BEGIN {
            srand()
        }
        {
            length_value = length($0)
            for (i = 1; i <= length_value; i++) {
                chars[i] = substr($0, i, 1)
            }
            for (i = length_value; i > 1; i--) {
                j = int(rand() * i) + 1
                temp = chars[i]
                chars[i] = chars[j]
                chars[j] = temp
            }
            for (i = 1; i <= length_value; i++) {
                printf "%s", chars[i]
            }
            printf "\n"
        }
    '
}

if [ "$#" -gt 1 ]; then
    print_usage
    exit 1
fi

require_command awk
require_command head
require_command tr

if [ ! -r /dev/urandom ]; then
    echo "Error: /dev/urandom is not available." >&2
    exit 1
fi

LENGTH="${1:-10}"

if ! is_positive_integer "$LENGTH"; then
    echo "Error: length must be a positive integer." >&2
    exit 1
fi

if [ "$LENGTH" -lt 4 ]; then
    echo "Error: length must be at least 4." >&2
    exit 1
fi

UPPER="A-Z"
LOWER="a-z"
DIGIT="0-9"
SYMBOL="!@#$%^&*_=+"
ALL_CHARS="$UPPER$LOWER$DIGIT$SYMBOL"

PASSWORD="$(random_chars "$UPPER" 1)"
PASSWORD="$PASSWORD$(random_chars "$LOWER" 1)"
PASSWORD="$PASSWORD$(random_chars "$DIGIT" 1)"
PASSWORD="$PASSWORD$(random_chars "$SYMBOL" 1)"

REMAINING_LENGTH=$((LENGTH - 4))
if [ "$REMAINING_LENGTH" -gt 0 ]; then
    PASSWORD="$PASSWORD$(random_chars "$ALL_CHARS" "$REMAINING_LENGTH")"
fi

printf "%s\n" "$PASSWORD" | shuffle_password
