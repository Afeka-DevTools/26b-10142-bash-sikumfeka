#! /bin/bash

set -u

print_usage() {
    echo "Usage: $0 <city_name>"
    echo "Fetches current weather for a city using wttr.in."
    echo "Example: $0 Tel Aviv"
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required command '$1' is not installed." >&2
        echo "Install it and run the script again." >&2
        exit 1
    fi
}

url_encode() {
    local input="$1"
    local encoded=""
    local index=0
    local char=""
    local hex=""
    local LC_ALL=C
    local length=${#input}

    while [ "$index" -lt "$length" ]; do
        char="${input:$index:1}"
        case "$char" in
            [a-zA-Z0-9.~_-])
                encoded="${encoded}${char}"
                ;;
            *)
                hex="$(printf "%s" "$char" | od -An -tx1 | tr -d " \n" | tr "[:lower:]" "[:upper:]")"
                encoded="${encoded}%${hex}"
                ;;
        esac
        index=$((index + 1))
    done

    printf "%s" "$encoded"
}

if [ "$#" -lt 1 ]; then
    print_usage
    exit 1
fi

require_command curl
require_command od
require_command tr

CITY="$*"

case "$CITY" in
    *[![:space:]]*) ;;
    *)
        echo "Error: city name cannot be blank." >&2
        exit 1
        ;;
esac

ENCODED_CITY="$(url_encode "$CITY")"
URL="https://wttr.in/${ENCODED_CITY}?format=3"

echo "Fetching current weather for: $CITY"

WEATHER="$(curl -fsSL --retry 2 --connect-timeout 5 --max-time 12 -H "User-Agent: bash-weather-script/1.0" "$URL" 2>/dev/null)"
CURL_STATUS=$?

if [ "$CURL_STATUS" -ne 0 ] || [ -z "$WEATHER" ]; then
    echo "Error: could not fetch weather data. Check your internet connection or city name." >&2
    exit 1
fi

case "$WEATHER" in
    *"Unknown location"*)
        echo "Error: unknown city: $CITY" >&2
        exit 1
        ;;
esac

echo "$WEATHER"
