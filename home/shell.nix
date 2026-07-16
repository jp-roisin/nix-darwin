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
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "autojump" # brew
        "yarn"
        "brew"
        "tmux"
        "docker-compose"
        "docker"
      ];
      theme = "agnoster";
    };
  };

  home.shellAliases = {
    k = "kubectl";
    lg = "lazygit";
    oc = "opencode";
    vi = "nvim";
    vim = "nvim";
    python = "python3";
    pip = "pip3";
  };
}
