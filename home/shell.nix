{ username, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true; # home-manager sources this last, as required

    plugins = [
      {
        name = "alias-tips";
        src = pkgs.fetchFromGitHub {
          owner = "djui";
          repo = "alias-tips";
          rev = "41cb143ccc3b8cc444bf20257276cb43275f65c4";
          sha256 = "sha256-ZFWrwcwwwSYP5d8k7Lr/hL3WKAZmgn51Q9hYL3bq9vE=";
        };
        file = "alias-tips.plugin.zsh";
      }
    ];

    initContent = ''
      export DEFAULT_USER="${username}"
      export PATH="$PATH:$HOME/.local/bin:$HOME/go/bin"
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
      eval "$(mise activate zsh)"
      export PATH="/usr/local/texlive/2025/bin/universal-darwin:$PATH"
      export PATH="/Library/TeX/texbin:$PATH"
      export PATH="$HOME/bin:$PATH"
      export PATH="/opt/homebrew/opt/python@3.12/libexec/bin:$PATH" # unversioned python3/pip3 -> 3.12 (keg-only)
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "autojump" # nix, see environment.pathsToLink in modules/apps.nix
        "yarn"
        "brew"
        "docker-compose"
        "docker"
      ];
      theme = "agnoster";
    };
  };

  # trying out nushell: run `nu` from zsh (inherits PATH/env), zsh stays the login shell
  programs.nushell = {
    enable = true;
    # mirrors the PATH/mise/homebrew setup that zsh does in initContent and oh-my-zsh's brew plugin
    extraEnv = ''
      $env.PATH = ($env.PATH | split row (char esep)
        | prepend [
          /opt/homebrew/opt/python@3.12/libexec/bin
          ($env.HOME | path join bin)
          /Library/TeX/texbin
          /usr/local/texlive/2025/bin/universal-darwin
          ($env.HOME | path join .cargo/bin)
          /opt/homebrew/bin
          /opt/homebrew/sbin
        ]
        | append [ ($env.HOME | path join .local/bin) ($env.HOME | path join go/bin) ]
        | uniq)
      let autoload = ($nu.data-dir | path join vendor/autoload)
      mkdir $autoload
      ^mise activate nu | save -f ($autoload | path join mise.nu)
    '';
    # oh-my-zsh plugin aliases: git/docker from nu_scripts, the rest ported by hand
    extraConfig = ''
      # nu highlights natively; make it flag unknown commands like zsh-syntax-highlighting (green found, red not)
      $env.config.highlight_resolved_externals = true
      $env.config.color_config.shape_external = "red"
      $env.config.color_config.shape_external_resolved = "green"
      $env.config.color_config.shape_internalcall = "green_bold"
      use ${pkgs.nu_scripts}/share/nu_scripts/aliases/git/git-aliases.nu *
      use ${pkgs.nu_scripts}/share/nu_scripts/aliases/docker/docker-aliases.nu *
      ${builtins.readFile ./aliases.nu}
    '';
  };

  # tab completions for external commands (git, docker, brew, ...) in nu
  programs.carapace = {
    enable = true;
    enableZshIntegration = false; # zsh keeps oh-my-zsh completions
  };

  # agnoster-style prompt for nu: current folder / git branch
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = false; # zsh keeps oh-my-zsh's agnoster
    settings = let
      # nix strings have no \u escapes, decode nerd font glyphs via JSON
      glyph = code: builtins.fromJSON ''"\u${code}"'';
      segment = attrs: {
        style = "powerline";
        powerline_symbol = glyph "e0b0"; # arrow
        foreground = "#100e23";
      } // attrs;
    in {
      version = 4;
      final_space = true;
      blocks = [{
        type = "prompt";
        alignment = "left";
        segments = [
          (segment { type = "path"; background = "blue"; template = " {{ .Path }} "; options.style = "folder"; })
          (segment {
            type = "git";
            background = "green";
            # terminal ANSI colors (same as zsh agnoster): green, yellow when there are uncommitted changes
            background_templates = [ "{{ if or .Working.Changed .Staging.Changed }}yellow{{ end }}" ];
            template = " {{ .HEAD }} ";
            options.fetch_status = true;
          })
        ];
      }];
    };
  };

  home.shellAliases = {
    k = "kubectl";
    lg = "lazygit";
    ldk = "lazydocker";
    oc = "opencode";
    vi = "nvim";
    vim = "nvim";
    python = "python3";
    pip = "pip3";
    xx = "exit";
  };
}
