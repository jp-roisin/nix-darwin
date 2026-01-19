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


  ];

  programs = {
    alacritty = {
      enable = true;
      settings = {
        # Theme automatically switches based on macOS appearance
        # Managed by scripts/alacritty_theme_switcher.sh
        general.import = [ "~/.config/alacritty/alacritty-theme/themes/active-theme.toml" ];
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

      extraConfig = builtins.readFile ./tmux.conf;
    };

    # modern vim
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
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
