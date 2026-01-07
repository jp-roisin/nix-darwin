{ username, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initContent = ''
      export DEFAULT_USER="${username}"
      export PATH="$PATH:/usr/local/go/bin:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      export PATH="$HOME/.local/share/mise/installs/node/22.17.0/bin:$PATH"
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
      eval "$(mise activate zsh)"
      export PATH="/usr/local/texlive/2025/bin/universal-darwin:$PATH"
      export PATH="/Library/TeX/texbin:$PATH"
      export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH:$PATH"
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

        # --- Manual install ---
        # move plugins from:
        # /nix/store/0yx9ynxcwik7kkgnvypblpzpqsxs50dl-oh-my-zsh-2025-09-27/share/oh-my-zsh/custom/plugins
        # to the new hash after running `nix flask update`
        "alias-tips"
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
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

    # urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    # urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  };
}
