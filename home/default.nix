{ username, lib, ... }:
{
  # import sub modules
  imports = [
    ./shell.nix
    ./core.nix
    ./git.nix
    # ./starship.nix
  ];

  # Run theme switcher on home-manager activation to set initial theme
  home.activation.alacrittyThemeSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD /Users/${username}/.nix-profile/bin/alacritty-theme-switcher 2>/dev/null || true
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
