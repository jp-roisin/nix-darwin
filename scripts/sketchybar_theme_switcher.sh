#!/usr/bin/env bash
# SketchyBar Theme Switcher - reloads sketchybar so it picks up the
# current macOS appearance (colors are selected in ~/.config/sketchybar/colors.sh).

set -euo pipefail

SKETCHYBAR_BIN="/opt/homebrew/bin/sketchybar"
STATE_FILE="${TMPDIR:-/tmp}/sketchybar-theme.state"

# Only act if sketchybar is installed and running.
if [ ! -x "$SKETCHYBAR_BIN" ]; then
    exit 0
fi

if ! pgrep -x sketchybar >/dev/null 2>&1; then
    exit 0
fi

# Idempotent: only reload when the appearance actually differs from what we
# last applied, so the monitor can call us every loop without reloading the
# bar on every tick.
appearance=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")
last=$(cat "$STATE_FILE" 2>/dev/null || echo "")

if [ "$appearance" != "$last" ]; then
    "$SKETCHYBAR_BIN" --reload
    echo "$appearance" >"$STATE_FILE" 2>/dev/null || true
fi
