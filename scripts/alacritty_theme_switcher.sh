#!/usr/bin/env bash
# Alacritty Theme Switcher - switches theme based on macOS appearance

set -euo pipefail

THEME_DIR="$HOME/.config/alacritty/themes"
ACTIVE_THEME_LINK="$THEME_DIR/active-theme.toml"
DARK_THEME="custom_ayu_mirage.toml"
LIGHT_THEME="ayu_light.toml"

# Get current macOS appearance (returns "Dark" or "Light")
appearance=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")

# Select theme based on appearance
if [[ "$appearance" == "Dark" ]]; then
    theme="$DARK_THEME"
else
    theme="$LIGHT_THEME"
fi

# Update symlink to point to selected theme
ln -sf "$THEME_DIR/$theme" "$ACTIVE_THEME_LINK"

# Touch alacritty config to trigger reload
touch "$HOME/.config/alacritty/alacritty.toml" 2>/dev/null || true
