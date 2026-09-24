{ pkgs, lib, config, herdr, openspec, pi, ... }:
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
    helix
    lazygit
    lazydocker
    sqlite
    pam-reattach # Enable TouchID in tmux sessions
    herdr.packages.${pkgs.stdenv.hostPlatform.system}.default # terminal workspace manager
    openspec.packages.${pkgs.stdenv.hostPlatform.system}.default # spec-driven dev CLI
    pi.packages.${pkgs.stdenv.hostPlatform.system}.default # pi coding agent

    # Migrated from homebrew
    autojump
    mise
    lua-language-server
    git-filter-repo
    jankyborders # felixkratz/formulae/borders
    sketchybar
    transmission_4 # transmission-cli
    texlab
    yt-dlp
    ffmpeg
    youplot
    pandoc
    htop
    mas
    watchman
    postgresql_18
    opencode
    redis
    luaPackages.luacheck
    tty-share
    gh
    stripe-cli
    watchexec
    cocoapods
  ];

  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # Homebrew deprecated `brew bundle --cleanup` and now exits non-zero on it,
      # which aborts darwin-rebuild activation. Both "uninstall" and "zap" pass
      # --cleanup, so use "none" to keep activation green.
      # To prune unlisted formulae manually: `brew bundle cleanup --force`
      cleanup = "none";
    };

    # `brew tap`
    taps = [
      "nikitabobko/tap"
      "modem-dev/tap"
    ];

    # `brew install`
    brews = [
      "cliclick" # read cursor position (sketchybar menu-bar auto-hide); not in nixpkgs
      "modem-dev/tap/hunk" # custom tap, not in nixpkgs
      "nx" # not in nixpkgs

      # ungoogled-chromium-macos build utils
      "python@3.12"
      "ninja"
      "coreutils"
      "readline"
      "quilt"
    ];

    # `brew install --cask`
    casks = [
      "waterfox"
      "alacritty"
      "alfred"
      "spotify"
      "logseq"
      "bruno"
      "signal"
      "nikitabobko/tap/aerospace"
      "gimp"
      "tailscale-app"
      "jellyfin-media-player"
      "discord"
      "vlc"
      "mactex"
      "whatsapp"
      "docker-desktop"
      "microsoft-teams"
      "inkscape"
      "raspberry-pi-imager"
      "datagrip"
      "redis-insight"
      "zed"
      # "protonvpn"
      "claude-code"
      "obsidian"
      "onlyoffice"

      # Requiring: scripts/brew_no_quarantine.sh
      "chromium"
    ];

    # `mas install`
    # Disabled: `mas list` returns nothing because /Applications isn't in the
    # Spotlight index, so brew bundle reinstalls all three on every rebuild.
    # Re-enable once `mas list` shows them (`sudo mdutil -E /System/Volumes/Data`).
    masApps = {
      # Xcode = 497799835;
      # Pages = 361309726;
      # Numbers = 361304891;
    };
  };

  # A single flaky Homebrew package (app running during upgrade, transient
  # download failure, upstream hiccup) shouldn't abort the whole rebuild.
  # Same command as upstream nix-darwin, but warns instead of exiting.
  system.activationScripts.homebrew.text = lib.mkForce ''
    # Homebrew Bundle
    echo >&2 "Homebrew bundle..."
    if [ -f "${config.homebrew.prefix}/bin/brew" ]; then
      ${config.homebrew.onActivation.brewBundleCmd { onlyCheck = false; }} || {
        printf >&2 '\n\e[1;33m%s\e[0m\n' "######################################################################"
        printf >&2 '\e[1;33m%s\e[0m\n'   "##                                                                  ##"
        printf >&2 '\e[1;33m%s\e[0m\n'   "##   WARNING: brew bundle FAILED                                    ##"
        printf >&2 '\e[1;33m%s\e[0m\n'   "##   Some Homebrew packages are NOT installed or upgraded.          ##"
        printf >&2 '\e[1;33m%s\e[0m\n'   "##   Activation continued anyway - re-run 'make build' to retry.    ##"
        printf >&2 '\e[1;33m%s\e[0m\n'   "##                                                                  ##"
        printf >&2 '\e[1;33m%s\e[0m\n\n' "######################################################################"
      }
    else
      echo -e "\e[1;31merror: Homebrew is not installed, skipping...\e[0m" >&2
    fi
  '';
}
