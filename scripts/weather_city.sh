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

if [ "$#" -lt 1 ]; then
    print_usage
    exit 1
fi

require_command curl
require_command sed

CITY="$*"
ENCODED_CITY="$(printf '%s' "$CITY" | sed 's/ /+/g')"
URL="https://wttr.in/${ENCODED_CITY}?format=3"

echo "Fetching current weather for: $CITY"

WEATHER="$(curl -fsSL --max-time 10 "$URL" 2>/dev/null)"
CURL_STATUS=$?

if [ "$CURL_STATUS" -ne 0 ] || [ -z "$WEATHER" ]; then
    echo "Error: could not fetch weather data. Check your internet connection or city name." >&2
    exit 1
fi

echo "$WEATHER"
