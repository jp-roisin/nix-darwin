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
      # "aria2"  # download tool
    ];

    # `brew install --cask`
    casks = [
      "firefox"
      "amethyst"
      "alacritty"
      "alfred"
      "spotify"
      "logseq"
      "bruno"

      # Add someday
      # "google-chrome"
      # "visual-studio-code"
    ];
  };
}
