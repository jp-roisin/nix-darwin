{
  username,
  lib,
  pkgs,
  ...
}: {
  # import sub modules
  imports = [
    ./shell.nix
    ./core.nix
    ./git.nix
    ./borders.nix
    ./sketchybar.nix
  ];

  home.file.".config/aerospace/aerospace.toml" = {
    force = true; # overwrite existing file
    source = ./aerospace.toml;
  };

  home.file.".config/herdr/config.toml" = {
    force = true; # overwrite existing file
    source = ./herdr.toml;
  };

  # opencode config. Managed declaratively so `make build` always resets it to
  # this known-good version — opencode's own plugin/schema migrations otherwise
  # rewrite the file in place (leaving the .bak / .tui-migration.bak droppings).
  #
  # NOTE: this becomes a read-only symlink into the nix store, so opencode can no
  # longer migrate it on a schema bump. When opencode changes its schema, edit
  # the JSON here and rebuild rather than letting opencode rewrite it.
  home.file.".config/opencode/opencode.json" = {
    force = true; # overwrite the existing hand-managed file
    source = ./opencode.json;
  };

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

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
