#!/usr/bin/env bash
# Monitors macOS appearance changes and triggers theme switcher

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_SWITCHER="$SCRIPT_DIR/alacritty_theme_switcher.sh"
CHECK_INTERVAL=5  # seconds

# Run once on startup
"$THEME_SWITCHER"

# Store previous appearance state
previous_appearance=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")

# Monitor for changes
while true; do
    sleep "$CHECK_INTERVAL"

    current_appearance=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")

    # Only run switcher if appearance changed
    if [[ "$current_appearance" != "$previous_appearance" ]]; then
        "$THEME_SWITCHER"
        previous_appearance="$current_appearance"
    fi
done
