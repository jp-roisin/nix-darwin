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
    helix
    lazygit
    sqlite
    pam-reattach # Enable TouchID in tmux sessions
  ];

  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap"; # 'zap': uninstalls all formulae(and related files) not listed here.
    };

    # `brew tap`
    taps = [
      "FelixKratz/formulae"
      "nikitabobko/tap"
    ];

    # `brew install`
    brews = [
      "autojump"
      "rustup" # Install rust using `rustup-init`
      "mise"
      "lua-language-server"
      "git-filter-repo"
      "felixkratz/formulae/borders"
      "transmission-cli"
      "texlab"
      "yt-dlp"
      "ffmpeg"
      "youplot"
      "pandoc"
      "vue-language-server"
      "libpq"
      "htop"
      "mas"
      "watchman"
      "postgresql@18"
      "opencode"
      "redis"
      "luacheck"
      "tty-share"
    ];

    # `brew install --cask`
    casks = [
      "firefox"
      "waterfox"
      "alacritty"
      "alfred"
      "spotify"
      "logseq"
      "bruno"
      "signal"
      "stats"
      "nikitabobko/tap/aerospace"
      "gimp"
      "zen"
      "tailscale-app"
      "jellyfin-media-player"
      "discord"
      "vlc"
      "anki"
      "mactex"
      "whatsapp"
      "docker-desktop"
      "microsoft-teams"
      "inkscape"
      "visual-studio-code"
      "webstorm"
      "raspberry-pi-imager"

      # Requiring: scripts/brew_no_quarantine.sh
      "chromium"
    ];

    # `mas install`
    masApps = {
      Xcode = 497799835;
    };
  };
}
