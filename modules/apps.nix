{ pkgs, ... }:
{

  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  #  NOTE: Your can find all available options in:
  #    https://daiderd.com/nix-darwin/manual/index.html
  #
  ##########################################################################

  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    git
    neovim
    helix
    lazygit
    sqlite
  ];

  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      cleanup = "zap"; # 'zap': uninstalls all formulae(and related files) not listed here.
    };

    # taps = [
    #   "homebrew/services"
    # ];

    # `brew install`
    brews = [
      "autojump"
      "rustup" # Install rust using `rustup-init`
      "mise"
      "lua-language-server"
    ];

    # `brew install --cask`
    casks = [
      "firefox"
      "alacritty"
      "alfred"
      "spotify"
      "logseq"
      "bruno"
      "signal"
      "jellyfin"
      "stats"
      "nikitabobko/tap/aerospace"
      "gimp"
      "zen"

      # `brew install --no-quarantine --cask`
      # Requiring: scripts/brew_no_quarantine.sh
      "chromium"

      # Add someday
      # "visual-studio-code"
    ];
  };
}
