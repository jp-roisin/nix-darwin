{ ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initContent = ''
      export DEFAULT_USER="jp"
      export PATH="$PATH:/usr/local/go/bin:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
      eval "$(mise activate zsh)"
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "autojump" # brew
        "yarn"
        "brew"
        "tmux"

        # Manual install: /nix/store/7k1wqk4f0zr2kjsd60xpbs0x01k1wky3-oh-my-zsh-2025-06-19/share/oh-my-zsh/custom/plugins
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

    # urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    # urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  };
}
