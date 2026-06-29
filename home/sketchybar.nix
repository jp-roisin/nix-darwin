{ lib, ... }: {
  ##########################################################################
  #
  #  SketchyBar - minimal status bar, theme-aware (ayu mirage / ayu light)
  #
  #  - Left:  aerospace workspaces 1-10 (focused highlighted)
  #  - Right: wifi (icon) | battery (icon + %) | clock
  #
  #  Theme follows macOS appearance. Colors are re-evaluated on every
  #  `sketchybar --reload`, which is triggered by the shared appearance
  #  monitor (scripts/alacritty_theme_monitor.sh).
  #
  #  NOTE: In nix '' '' strings, bash variables must be written as ''${VAR}
  #  to avoid nix interpolation.
  #
  ##########################################################################

  # Reload the running sketchybar after a switch so config/plugin changes take
  # effect without a manual `sketchybar --reload` or relogin. No-op if the bar
  # is not running. Runs after files are written (writeBoundary).
  home.activation.reloadSketchybar =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if /usr/bin/pgrep -x sketchybar > /dev/null 2>&1; then
        run /opt/homebrew/bin/sketchybar --reload || true
      fi
    '';

  # Shared color palette + theme selection.
  home.file.".config/sketchybar/colors.sh" = {
    force = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Ayu palette mapped to sketchybar 0xAARRGGBB. Sourced by rc + plugins.

      # launchd-spawned plugins inherit a minimal PATH; fix it here since this
      # file is sourced by the rc and every plugin.
      export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

      appearance=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")

      if [[ "$appearance" == "Dark" ]]; then
        # Ayu Mirage
        export BAR_COLOR=0xff1f2430
        export FG_COLOR=0xffcbccc6
        export ACCENT_COLOR=0xfffdcc60
        export ICON_ACTIVE=0xff60b8d6
        export DIM_COLOR=0xff686868
        export GREEN_COLOR=0xff53bf97
        export RED_COLOR=0xfff08778
      else
        # Ayu Light
        export BAR_COLOR=0xfffcfcfc
        export FG_COLOR=0xff5c6166
        export ACCENT_COLOR=0xffeba54d
        export ICON_ACTIVE=0xff4196df
        export DIM_COLOR=0xffc1c1c1
        export GREEN_COLOR=0xff80ab24
        export RED_COLOR=0xffe7666a
      fi
    '';
  };

  # Main config / entrypoint.
  home.file.".config/sketchybar/sketchybarrc" = {
    force = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # launchd starts us with a minimal PATH; ensure homebrew bins are found.
      export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

      CONFIG_DIR="$HOME/.config/sketchybar"
      PLUGIN_DIR="$CONFIG_DIR/plugins"
      FONT="JetBrainsMono Nerd Font"

      source "$CONFIG_DIR/colors.sh"

      ##### Bar appearance #####
      sketchybar --bar \
        height=32 \
        position=top \
        margin=12 \
        y_offset=2 \
        corner_radius=12 \
        padding_left=8 \
        padding_right=8 \
        color="$BAR_COLOR"

      ##### Global defaults #####
      sketchybar --default \
        icon.font="$FONT:Bold:15.0" \
        icon.color="$FG_COLOR" \
        label.font="$FONT:Semibold:13.0" \
        label.color="$FG_COLOR" \
        padding_left=5 \
        padding_right=5 \
        background.corner_radius=6 \
        background.height=24

      ##### Left: aerospace workspaces #####
      sketchybar --add event aerospace_workspace_change

      for sid in 1 2 3 4 5; do
        sketchybar --add item space.$sid left \
          --subscribe space.$sid aerospace_workspace_change \
          --set space.$sid \
            icon="$sid" \
            icon.padding_left=8 \
            icon.padding_right=8 \
            label.drawing=off \
            click_script="aerospace workspace $sid" \
            script="$PLUGIN_DIR/aerospace.sh $sid"
      done

      ##### Right: wifi  battery  clock (added right-to-left) #####
      # No separators; extra left padding on each section provides the gap.
      sketchybar --add item clock right \
        --set clock \
          padding_left=16 \
          update_freq=1 \
          script="$PLUGIN_DIR/clock.sh"

      sketchybar --add item battery right \
        --set battery \
          icon.font="$FONT:Bold:16.0" \
          icon.padding_right=4 \
          padding_left=16 \
          update_freq=30 \
          script="$PLUGIN_DIR/battery.sh" \
        --subscribe battery system_woke power_source_change

      # Claude Max session usage %. Added before wifi so wifi sits to its left.
      # padding_left=16 gives the section gap (to its left, between it and wifi).
      # update_freq=300 (5 min) to avoid rate-limiting the usage endpoint.
      sketchybar --add item claude_usage right \
        --set claude_usage \
          icon.font="$FONT:Bold:16.0" \
          icon.padding_right=4 \
          padding_left=16 \
          update_freq=300 \
          script="$PLUGIN_DIR/claude_usage.sh" \
        --subscribe claude_usage system_woke

      sketchybar --add item wifi right \
        --set wifi \
          icon.font="$FONT:Bold:16.0" \
          update_freq=10 \
          script="$PLUGIN_DIR/wifi.sh" \
        --subscribe wifi wifi_change system_woke

      ##### Finalize #####
      sketchybar --update

      # Draw initial workspace highlight. On a fresh boot sketchybar may start
      # before AeroSpace is ready, so retry briefly (in the background, to not
      # block startup) and fall back to workspace 1 if it never answers.
      (
        focused=""
        for _ in $(seq 1 20); do
          focused=$(aerospace list-workspaces --focused 2>/dev/null)
          [ -n "$focused" ] && break
          sleep 0.5
        done
        [ -z "$focused" ] && focused=1
        sketchybar --trigger aerospace_workspace_change \
          FOCUSED_WORKSPACE="$focused"
      ) &
    '';
  };

  # Plugin: highlight focused workspace.
  home.file.".config/sketchybar/plugins/aerospace.sh" = {
    force = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      source "$HOME/.config/sketchybar/colors.sh"

      # $1 = this item's workspace id; FOCUSED_WORKSPACE from the event,
      # otherwise query aerospace directly (covers initial draw / forced).
      sid="$1"
      focused="''${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"

      if [[ "$sid" == "$focused" ]]; then
        sketchybar --set "$NAME" \
          icon.color="$BAR_COLOR" \
          background.color="$ACCENT_COLOR" \
          background.drawing=on
      else
        sketchybar --set "$NAME" \
          icon.color="$FG_COLOR" \
          background.drawing=off
      fi
    '';
  };

  # Plugin: battery icon + percentage.
  home.file.".config/sketchybar/plugins/battery.sh" = {
    force = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      source "$HOME/.config/sketchybar/colors.sh"

      batt=$(pmset -g batt)
      pct=$(echo "$batt" | grep -Eo "[0-9]+%" | head -1 | tr -d '%')
      charging=$(echo "$batt" | grep -c "AC Power")

      [[ -z "$pct" ]] && exit 0

      # Material Design battery glyphs as octal UTF-8 (works under /bin/sh,
      # which is how sketchybar invokes plugins; $'...' would not).
      if [[ "$charging" -gt 0 ]]; then
        icon=$(printf '\363\260\202\204')  # battery-charging F0084
      else
        case "$pct" in
          100|9[0-9]) icon=$(printf '\363\260\201\271') ;;  # battery full F0079
          [78][0-9])  icon=$(printf '\363\260\202\202') ;;  # battery-80 F0082
          [56][0-9])  icon=$(printf '\363\260\202\200') ;;  # battery-60 F0080
          [34][0-9])  icon=$(printf '\363\260\201\276') ;;  # battery-40 F007E
          [12][0-9])  icon=$(printf '\363\260\201\272') ;;  # battery-10 F007A
          *)          icon=$(printf '\363\260\201\273') ;;  # alert F007B
        esac
      fi

      # Icon uses the same color as text (FG); no state-based coloring.
      sketchybar --set "$NAME" \
        icon="$icon" \
        icon.color="$FG_COLOR" \
        label="''${pct}%"
    '';
  };

  # Plugin: wifi connected/disconnected icon only.
  home.file.".config/sketchybar/plugins/wifi.sh" = {
    force = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      source "$HOME/.config/sketchybar/colors.sh"

      ip=$(ipconfig getifaddr en0 2>/dev/null)

      # Material Design wifi glyphs as octal UTF-8 (sh-safe).
      # Icon uses the same color as text (FG); no state-based coloring.
      if [[ -n "$ip" ]]; then
        icon=$(printf '\363\260\226\251')  # wifi F05A9
      else
        icon=$(printf '\363\260\244\255')  # wifi-off F092D
      fi
      sketchybar --set "$NAME" icon="$icon" icon.color="$FG_COLOR" label.drawing=off
    '';
  };

  # Plugin: clock.
  home.file.".config/sketchybar/plugins/clock.sh" = {
    force = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      source "$HOME/.config/sketchybar/colors.sh"
      sketchybar --set "$NAME" icon.drawing=off label="$(date '+%a %d %b, %H:%M:%S')"
    '';
  };

  # Plugin: Claude Max (5x) current 5-hour session usage %.
  #
  # No official API. Reads the OAuth access token Claude Code stores locally
  # (~/.claude/.credentials.json, else the login keychain under service
  # "Claude Code-credentials") and calls the undocumented usage endpoint.
  # Response field .five_hour.utilization is the session % consumed.
  # Defensive: any missing token / curl failure / parse failure -> "--", exit 0.
  home.file.".config/sketchybar/plugins/claude_usage.sh" = {
    force = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      source "$HOME/.config/sketchybar/colors.sh"

      # Claude-style sparkle glyph (Material Design "creation" F0674) as octal
      # UTF-8 (sh-safe, like the battery/wifi items). No state-based coloring;
      # icon + label inherit the default FG color.
      icon=$(printf '\363\260\231\264')

      # Quiet fallback shown whenever anything goes wrong, so the bar never breaks.
      fail() {
        sketchybar --set "$NAME" icon="$icon" icon.color="$FG_COLOR" label="--"
        exit 0
      }

      # Read the OAuth token: credentials file first, then login keychain.
      creds=""
      if [ -f "$HOME/.claude/.credentials.json" ]; then
        creds=$(cat "$HOME/.claude/.credentials.json" 2>/dev/null)
      fi
      if [ -z "$creds" ]; then
        creds=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
      fi

      token=$(printf '%s' "$creds" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
      [ -z "$token" ] && fail

      resp=$(curl -s --max-time 5 \
        "https://api.anthropic.com/api/oauth/usage" \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" \
        -H "Content-Type: application/json" 2>/dev/null)

      pct=$(printf '%s' "$resp" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
      [ -z "$pct" ] && fail

      # Round to integer.
      pct=$(printf '%.0f' "$pct" 2>/dev/null)
      [ -z "$pct" ] && fail

      sketchybar --set "$NAME" icon="$icon" icon.color="$FG_COLOR" label="''${pct}%"
    '';
  };
}
