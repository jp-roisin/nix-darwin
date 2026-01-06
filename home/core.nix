{ pkgs, ... }:
{
  home.packages = with pkgs; [
    oh-my-zsh
    tmux
    zellij

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    fzf # A command-line fuzzy finder

    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing

    # misc
    which
    tree
    fastfetch
    bat

    # Explore
    file
    gnused
    gnutar
    gawk
    zstd
    caddy
    gnupg

    # productivity
    glow # markdown previewer in terminal

    # Alacritty theme switcher script
    (pkgs.writeShellScriptBin "alacritty-theme-switcher" ''
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
    '')
  ];

  programs = {
    alacritty = {
      enable = true;
      settings = {
        # Theme automatically switches based on macOS appearance
        # Managed by scripts/alacritty_theme_switcher.sh
        general.import = [ "~/.config/alacritty/themes/active-theme.toml" ];
        window = {
          dimensions = {
            columns = 80;
            lines = 24;
          };
          padding = {
            x = 12;
            y = 12;
          };
          dynamic_padding = false;
          decorations = "None";
          startup_mode = "Windowed";
          title = "Alacritty";
          class = {
            instance = "Alacritty";
            general = "Alacritty";
          };
        };

        env = {
          TERM = "xterm-256color";
        };

        font = {
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "JetBrainsMono Nerd Font";
            style = "Bold";
          };
          italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Italic";
          };
          bold_italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Bold Italic";
          };
          size = 16.0;
        };

        cursor = {
          style = "Block";
        };

        bell = {
          animation = "Ease";
        };

        scrolling = {
          history = 10000;
          multiplier = 3;
        };

        keyboard.bindings = [
          {
            key = "V";
            mods = "Control|Shift";
            action = "Paste";
          }
          {
            key = "C";
            mods = "Control|Shift";
            action = "Copy";
          }
          {
            key = "Plus";
            mods = "Control";
            action = "IncreaseFontSize";
          }
          {
            key = "Minus";
            mods = "Control";
            action = "DecreaseFontSize";
          }
          {
            key = "Equals";
            mods = "Control";
            action = "ResetFontSize";
          }
          {
            key = "F";
            mods = "Control";
            action = "SearchForward";
          }
          {
            key = "B";
            mods = "Control";
            action = "SearchBackward";
          }
        ];
      };
    };

    tmux = {
      enable = true;

      # Set prefix to Ctrl-Space
      shortcut = "C-Space";
      keyMode = "emacs";
      terminal = "$TERM";
      shell = "/bin/zsh";

      plugins = with pkgs.tmuxPlugins; [
        resurrect
        continuum
      ];

      extraConfig = ''
        # Reduce escape-time to allow Escape key to work immediately
        # Default is 500ms which causes delays when pressing Escape
        set -sg escape-time 10

        # Set prefix to Ctrl-Space
        unbind C-b
        bind C-Space send-prefix

        # Color for Alacritty
        set -ag terminal-overrides ",$TERM:Tc"

        # Split panes using v and h
        bind v split-window -h
        bind h split-window -v
        unbind '"'
        unbind %

        # Switch panes using Alt-arrow without prefix
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D

        # Reload tmux configuration
        bind r source-file ~/.config/tmux/tmux.conf

        # Start indexing at 1
        set -g base-index 1
        setw -g pane-base-index 1

        # Status bar at the top
        set -g status-position top
        set -g status-justify "left"
        set -g status-style "bg=default,fg=white"

        set -g status-left ""
        set -g window-status-current-format "#[bold,fg=yellow] #I "
        set -g window-status-current-style "bg=default"
        set -g window-status-format " #I "
        set -g window-status-style "bg=default,fg=white"

        set -g status-right "#[fg=white] %a %d %b │ \uf017 %H:%M "

        # set -g window-list "#[fg=white] #S "

        set -g status-bg "default"
        set -g status-interval 1

        # Enable mouse mode
        set -g mouse on

        # Pane border styling
        set -g pane-border-status top
        set -g pane-border-format ""

        set-window-option -g pane-active-border-style fg=white

        # tmux-resurrect
        # Save session: prefix + Ctrl-s (Ctrl-Space + Ctrl-s)
        # Restore session: prefix + Ctrl-r (Ctrl-Space + Ctrl-r)

        # tmux-continuum
        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '15'
      '';
    };

    # modern vim
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };

    # A modern replacement for ‘ls’
    # useful in bash/zsh prompt, not in nushell.
    eza = {
      enable = true;
      git = true;
      icons = "auto";
      enableZshIntegration = true;
    };

    # terminal file manager
    yazi = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
          sort_dir_first = true;
        };
      };
    };

    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
