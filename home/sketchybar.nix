{...}: {
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
        export BAR_COLOR=0xf01f2430
        export FG_COLOR=0xffcbccc6
        export ACCENT_COLOR=0xfffdcc60
        export ICON_ACTIVE=0xff60b8d6
        export DIM_COLOR=0xff686868
        export GREEN_COLOR=0xff53bf97
        export RED_COLOR=0xfff08778
      else
        # Ayu Light
        export BAR_COLOR=0xf0fcfcfc
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

      for sid in $(aerospace list-workspaces --all); do
        sketchybar --add item space.$sid left \
          --subscribe space.$sid aerospace_workspace_change \
          --set space.$sid \
            icon="$sid" \
            label.drawing=off \
            click_script="aerospace workspace $sid" \
            script="$PLUGIN_DIR/aerospace.sh $sid"
      done

      ##### Right: clock | battery | wifi (added right-to-left) #####
      sketchybar --add item clock right \
        --set clock \
          update_freq=1 \
          script="$PLUGIN_DIR/clock.sh"

      sketchybar --add item battery right \
        --set battery \
          update_freq=30 \
          script="$PLUGIN_DIR/battery.sh" \
        --subscribe battery system_woke power_source_change

      sketchybar --add item wifi right \
        --set wifi \
          update_freq=10 \
          script="$PLUGIN_DIR/wifi.sh" \
        --subscribe wifi wifi_change system_woke

      ##### Finalize #####
      sketchybar --update

      # Draw initial workspace highlight (no event has fired yet on startup).
      sketchybar --trigger aerospace_workspace_change \
        FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused)"
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

      color="$FG_COLOR"
      if [[ "$charging" -gt 0 ]]; then
        icon=""
        color="$GREEN_COLOR"
      else
        case "$pct" in
          100|9[0-9]) icon="" ;;
          [78][0-9]) icon="" ;;
          [56][0-9]) icon="" ;;
          [34][0-9]) icon="" ;;
          [12][0-9]) icon="" ;;
          *) icon=""; color="$RED_COLOR" ;;
        esac
      fi

      sketchybar --set "$NAME" \
        icon="$icon" \
        icon.color="$color" \
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

      if [[ -n "$ip" ]]; then
        sketchybar --set "$NAME" icon="" icon.color="$ICON_ACTIVE" label.drawing=off
      else
        sketchybar --set "$NAME" icon="" icon.color="$DIM_COLOR" label.drawing=off
      fi
    '';
  };

  # Plugin: clock.
  home.file.".config/sketchybar/plugins/clock.sh" = {
    force = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      source "$HOME/.config/sketchybar/colors.sh"
      sketchybar --set "$NAME" icon="" label="$(date '+%a %d %b, %H:%M:%S')"
    '';
  };
}
