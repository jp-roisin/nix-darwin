{ pkgs, ... }:
{
  home.sessionVariables.EDITOR = "nvim";

  home.packages = with pkgs; [
    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    neovim # editor; config lives in ~/.config/nvim (NvChad, not managed by home-manager)
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    fzf # A command-line fuzzy finder

    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing

    # misc
    tree
    fastfetch
    bat

    # productivity
    glow # markdown previewer in terminal

    # coding agent (pinned by the flake lock; `make upgrade` bumps it)
    claude-code

    # expo tooling
    eas-cli

    # rust toolchain
    rustc
    cargo
    clippy
    rustfmt
    rust-analyzer
    diesel-cli

    # go toolchain
    go
    gopls

    # gleam toolchain (erlang needed by lustre dev tools)
    gleam
    beamPackages.erlang
    rebar3

    # swift tooling (compiler and sourcekit-lsp come from Xcode)
    swiftformat
    swiftlint

    # kotlin toolchain (JDK via programs.java below)
    kotlin
    kotlin-language-server
    ktlint
    gradle
  ];

  programs = {
    # Sets JAVA_HOME so gradle/kotlin use nix's JDK over the system Temurin 17
    java.enable = true;

    alacritty = {
      enable = true;
      # The app itself comes from the homebrew cask; home-manager only writes
      # the config so alacritty isn't installed twice.
      package = null;
      settings = {
        # Theme automatically switches based on macOS appearance
        # Managed by scripts/alacritty_theme_switcher.sh
        general.import = [ "~/.config/alacritty/alacritty-theme/themes/active-theme.toml" ];
        # nushell as the terminal's shell. Launched via a login zsh (no .zshrc, ~5ms) so it
        # inherits the nix-darwin/home-manager environment; $SHELL stays zsh for other tools.
        terminal.shell = {
          program = "/bin/zsh";
          args = [ "-l" "-c" "exec nu" ];
        };
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
          decorations = "Buttonless";
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

    # terminal file manager
    yazi = {
      enable = true;
      shellWrapperName = "yy";
      enableZshIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
          sort_dir_first = true;
        };
      };
    };
  };
}
