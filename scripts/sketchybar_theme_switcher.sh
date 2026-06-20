#!/usr/bin/env bash
# SketchyBar Theme Switcher - reloads sketchybar so it picks up the
# current macOS appearance (colors are selected in ~/.config/sketchybar/colors.sh).

set -euo pipefail

SKETCHYBAR_BIN="/opt/homebrew/bin/sketchybar"

# Only act if sketchybar is installed and running.
if [ ! -x "$SKETCHYBAR_BIN" ]; then
    exit 0
fi

if ! pgrep -x sketchybar >/dev/null 2>&1; then
    exit 0
fi

"$SKETCHYBAR_BIN" --reload
