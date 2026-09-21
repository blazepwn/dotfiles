#!/usr/bin/env bash

set -euo pipefail

MODE="${1:-}"
OUTPUT_DIR="${HOME}/Pictures/Screenshots"
TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
FILE_PATH="${OUTPUT_DIR}/Screenshot_${TIMESTAMP}.png"
EDITED_PATH="${OUTPUT_DIR}/Screenshot_${TIMESTAMP}_edited.png"

mkdir -p "${OUTPUT_DIR}"

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        notify-send "Screenshot" "Missing dependency: $1" 2>/dev/null || true
        printf 'Missing dependency: %s\n' "$1" >&2
        exit 1
    fi
}

notify_done() {
    local target="$1"
    notify-send "Screenshot saved" "$(basename "$target") copied to clipboard" 2>/dev/null || true
}

capture_full() {
    grim -t png "${FILE_PATH}"
}

capture_region() {
    local geometry="${SCREENSHOT_GEOM:-}"

    if [ -z "${geometry}" ]; then
        geometry="$(slurp)"
    fi

    if [ -z "${geometry}" ]; then
        exit 0
    fi

    grim -g "${geometry}" -t png "${FILE_PATH}"
}

post_process() {
    if ! command -v magick >/dev/null 2>&1; then
        cp "${FILE_PATH}" "${EDITED_PATH}"
        return
    fi

    magick "${FILE_PATH}" \
        -gravity South \
        -font "Hack-Nerd-Font-Regular" \
        -pointsize 30 \
        -fill "#6791c9" \
        -annotate +0+18 "    eaguilarm  " \
        "${EDITED_PATH}"
}

copy_image() {
    wl-copy --type image/png < "${EDITED_PATH}"
}

require_command grim
require_command wl-copy

case "${MODE}" in
    full)
        capture_full
        ;;
    region)
        require_command slurp
        capture_region
        ;;
    *)
        printf 'Usage: %s [full|region]\n' "$0" >&2
        exit 1
        ;;
esac

post_process
copy_image
notify_done "${EDITED_PATH}"
