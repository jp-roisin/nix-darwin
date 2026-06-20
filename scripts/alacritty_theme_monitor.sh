#!/usr/bin/env bash
# Reconciles app themes with the macOS appearance (shared by alacritty and
# sketchybar). Level-triggered: every loop it runs the switchers, which are
# idempotent and only act when their state is out of sync. This self-heals any
# missed transition (e.g. an appearance toggle while an agent was restarting)
# within one poll interval, instead of relying on edge detection.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_SWITCHER="$SCRIPT_DIR/alacritty_theme_switcher.sh"
SKETCHYBAR_SWITCHER="$SCRIPT_DIR/sketchybar_theme_switcher.sh"
CHECK_INTERVAL=2  # seconds

# Run all switchers, tolerating individual failures.
run_switchers() {
    "$THEME_SWITCHER" || true
    "$SKETCHYBAR_SWITCHER" || true
}

# Reconcile continuously; switchers are no-ops when already in sync.
while true; do
    run_switchers
    sleep "$CHECK_INTERVAL"
done
