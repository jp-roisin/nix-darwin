#!/usr/bin/env bash
# Hide sketchybar while the cursor is in the macOS menu-bar reveal zone,
# so the (auto-hidden) native menu bar is readable instead of overlapping
# the translucent sketchybar. Shows it again once the cursor leaves.

set -uo pipefail

SKETCHYBAR_BIN="/opt/homebrew/bin/sketchybar"
CLICLICK_BIN="/opt/homebrew/bin/cliclick"

# Top reveal zone in points. Notch MacBooks reveal up to ~38px; non-notch ~25.
ZONE_HEIGHT=38
POLL_INTERVAL=0.15  # seconds; small for snappy feel

# Bail out cleanly if dependencies are missing.
[ -x "$SKETCHYBAR_BIN" ] || exit 0
[ -x "$CLICLICK_BIN" ] || exit 0

hidden="off"

while true; do
    # cliclick p prints "x,y" with a top-left origin in points.
    pos=$("$CLICLICK_BIN" p 2>/dev/null)
    y=${pos##*,}

    if [[ "$y" =~ ^[0-9]+$ ]]; then
        if [[ "$y" -le "$ZONE_HEIGHT" ]]; then
            want="on"
        else
            want="off"
        fi

        if [[ "$want" != "$hidden" ]]; then
            "$SKETCHYBAR_BIN" --bar hidden="$want" >/dev/null 2>&1
            hidden="$want"
        fi
    fi

    sleep "$POLL_INTERVAL"
done
