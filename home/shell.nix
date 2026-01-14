{ username, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Declarative plugin management
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "alias-tips";
        src = pkgs.fetchFromGitHub {
          owner = "djui";
          repo = "alias-tips";
          rev = "master";  # Tracks latest master branch
          sha256 = "sha256-ZFWrwcwwwSYP5d8k7Lr/hL3WKAZmgn51Q9hYL3bq9vE=";
        };
        file = "alias-tips.plugin.zsh";
      }
      {
        # IMPORTANT: Must be loaded last
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];

    initContent = ''
      export DEFAULT_USER="${username}"
      export PATH="$PATH:/usr/local/go/bin:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
      eval "$(mise activate zsh)"
      export PATH="/usr/local/texlive/2025/bin/universal-darwin:$PATH"
      export PATH="/Library/TeX/texbin:$PATH"
      export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"
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
      # theme = "gozilla";
      theme = "agnoster";
    };
  };

  home.shellAliases = {
    k = "kubectl";
    lg = "lazygit";
    oc = "opencode";
    vi = "nvim";
    vim = "nvim";

    # urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    # urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  };
}
