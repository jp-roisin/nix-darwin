#!/bin/zsh

# Only strip when present: once cleared, macOS App Management blocks xattr
# on the bundle and the failing -r walk would break `make build`.
app=/Applications/Chromium.app
xattr -p com.apple.quarantine "$app" >/dev/null 2>&1 || exit 0
xattr -rd com.apple.quarantine "$app"
