#!/usr/bin/env bash
# Monitors macOS appearance changes and triggers theme switchers
# (shared by alacritty and sketchybar)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_SWITCHER="$SCRIPT_DIR/alacritty_theme_switcher.sh"
SKETCHYBAR_SWITCHER="$SCRIPT_DIR/sketchybar_theme_switcher.sh"
CHECK_INTERVAL=3  # seconds

# Run all switchers, tolerating individual failures.
run_switchers() {
    "$THEME_SWITCHER" || true
    "$SKETCHYBAR_SWITCHER" || true
}

# Run once on startup
run_switchers

# Store previous appearance state
previous_appearance=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")

# Monitor for changes
while true; do
    sleep "$CHECK_INTERVAL"

    current_appearance=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")

    # Only run switchers if appearance changed
    if [[ "$current_appearance" != "$previous_appearance" ]]; then
        run_switchers
        previous_appearance="$current_appearance"
    fi
done
