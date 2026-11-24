#!/usr/bin/env bash
# Helix Theme Switcher - points the "macos" theme (set in home/helix.toml) at
# ayu_light or ayu_mirage based on macOS appearance. evil-helix has no native
# light/dark theme support, so we rewrite a tiny inheriting theme file.

set -euo pipefail

USER_HOME="${HOME:-$(eval echo ~$(whoami))}"
THEME_FILE="$USER_HOME/.config/helix/themes/macos.toml"

appearance=$(/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")
if [[ "$appearance" == "Dark" ]]; then
    desired='inherits = "ayu_mirage"'
else
    desired='inherits = "ayu_light"'
fi

# Idempotent: only rewrite + reload when the theme actually changes.
if [ "$(cat "$THEME_FILE" 2>/dev/null || true)" != "$desired" ]; then
    mkdir -p "$(dirname "$THEME_FILE")"
    echo "$desired" >"$THEME_FILE"
    # SIGUSR1 makes running helix instances reload config (and the theme).
    # The nix wrapper execs .hx-wrapped, so match on that name.
    /usr/bin/pkill -USR1 -f '/bin/\.hx-wrapped' 2>/dev/null || true
fi
