{ username, lib, pkgs, ... }:
{
  # import sub modules
  imports = [
    ./shell.nix
    ./core.nix
    ./git.nix
    ./borders.nix
    ./aerospace.nix
    # ./starship.nix
  ];

  # Clone alacritty-theme repository if it doesn't exist (for new machines)
  home.activation.cloneAlacrittyThemes = lib.hm.dag.entryAfter ["writeBoundary"] ''
    REPO_DIR="$HOME/.config/alacritty/alacritty-theme"

    if [ ! -d "$REPO_DIR/.git" ]; then
      $VERBOSE_ECHO "Cloning alacritty-theme repository..."
      $DRY_RUN_CMD mkdir -p "$HOME/.config/alacritty"
      $DRY_RUN_CMD ${lib.getExe pkgs.git} clone https://github.com/alacritty/alacritty-theme.git "$REPO_DIR"
    fi
  '';

  # Run theme switcher on home-manager activation to set initial theme
  home.activation.alacrittyThemeSetup = lib.hm.dag.entryAfter ["cloneAlacrittyThemes"] ''
    $DRY_RUN_CMD /etc/nix-darwin/scripts/alacritty_theme_switcher.sh 2>/dev/null || true
  '';

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
