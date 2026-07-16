{
  pkgs,
  username,
  ...
}: {
  system = {
    primaryUser = username;
    stateVersion = 6;
    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.

    # Trust Homebrew taps before homebrew activation runs (preActivation runs before the
    # homebrew bundle step in the activation ordering).
    activationScripts.preActivation.text = ''
      for tap in nikitabobko/tap modem-dev/tap; do
        sudo -H -u ${username} /opt/homebrew/bin/brew trust "$tap" 2>/dev/null || true
      done
    '';

    # Restart user agents after every rebuild so they pick up new scripts/
    # plists without a manual relaunch. kickstart -k = kill + (re)start, and
    # also starts an agent that was not running. Order respects dependencies
    # (aerospace before the things that query it).
    activationScripts.postActivation.text = ''
      echo "Restarting user agents..."
      uid=$(id -u ${username})

      # Long-running agents we expect to stay alive after (re)start. macOS can
      # kill a hardened binary with OS_REASON_CODESIGNING on the immediate
      # restart after a SIGKILL, so verify it actually came up and retry.
      for svc in \
        borders \
        sketchybar \
        sketchybar-menubar-watch \
        alacritty-theme-monitor; do
        target="gui/$uid/org.nixos.$svc"
        for _ in 1 2 3 4 5; do
          /bin/launchctl kickstart -k "$target" 2>/dev/null || true
          sleep 1
          if /bin/launchctl print "$target" 2>/dev/null | grep -q "state = running"; then
            break
          fi
        done
      done

      # aerospace is launched via `open -a`; the agent exits 0 once the app is
      # up, so just (re)start it without expecting the agent to stay running.
      /bin/launchctl kickstart -k "gui/$uid/org.nixos.aerospace" 2>/dev/null || true
    '';

    defaults = {
      menuExtraClock.Show24Hour = true; # show 24 hour clock

      # universalaccess.reduceMotion = true; # workspace animation - disabled due to permission issues

      hitoolbox.AppleFnUsageType = null;

      # customize dock
      dock = {
        autohide = true;
        show-recents = false; # disable recent apps
        tilesize = 128;
        autohide-delay = 0.0;
        expose-animation-duration = 0.0;
        orientation = "right";
      };

      # customize finder
      finder = {
        _FXShowPosixPathInTitle = true; # show full path in finder title
        AppleShowAllExtensions = true; # show all file extensions
        FXEnableExtensionChangeWarning = false; # disable warning when changing file extension
        QuitMenuItem = true; # enable quit menu item
        ShowPathbar = true; # show path bar
        ShowStatusBar = true; # show status bar
      };

      # customize trackpad
      trackpad = {
        # tap - 轻触触摸板, click - 点击触摸板
        Clicking = true; # enable tap to click(轻触触摸板相当于点击)
        TrackpadRightClick = true; # enable two finger right click
        # TrackpadThreeFingerDrag = true;  # enable three finger drag
      };

      # customize settings that not supported by nix-darwin directly
      # Incomplete list of macOS `defaults` commands :
      #   https://github.com/yannbertrand/macos-defaults
      NSGlobalDomain = {
        _HIHideMenuBar = true;
        # `defaults read NSGlobalDomain "xxx"`
        "com.apple.swipescrolldirection" = false; # enable natural scrolling(default to true)
        "com.apple.sound.beep.feedback" = 0; # disable beep sound when pressing volume up/down key
        # AppleInterfaceStyle is not managed here — managed by the user via
        # System Settings, the theme monitor reads it at runtime.
        AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control.
        ApplePressAndHoldEnabled = false; # disable press and hold

        # If you press and hold certain keyboard keys when in a text area, the key’s character begins to repeat.
        # This is very useful for vim users, they use `hjkl` to move cursor.
        # sets how long it takes before it starts repeating.
        InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
        # sets how fast it repeats once it starts.
        KeyRepeat = 2; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)

        NSAutomaticCapitalizationEnabled = false; # disable auto capitalization(自动大写)
        NSAutomaticDashSubstitutionEnabled = false; # disable auto dash substitution(智能破折号替换)
        NSAutomaticPeriodSubstitutionEnabled = false; # disable auto period substitution(智能句号替换)
        NSAutomaticQuoteSubstitutionEnabled = false; # disable auto quote substitution(智能引号替换)
        NSAutomaticSpellingCorrectionEnabled = false; # disable auto spelling correction(自动拼写检查)
        NSNavPanelExpandedStateForSaveMode = true; # expand save panel by default(保存文件时的路径选择/文件名输入页)
        NSNavPanelExpandedStateForSaveMode2 = true;

        # Disable two fingers swipe between pages (browser navigation)
        AppleEnableMouseSwipeNavigateWithScrolls = false;
        AppleEnableSwipeNavigateWithScrolls = false;
      };

      # Customize settings that not supported by nix-darwin directly
      # see the source code of this project to get more undocumented options:
      #    https://github.com/rgcr/m-cli
      #
      # All custom entries can be found by running `defaults read` command.
      # or `defaults read xxx` to read a specific domain.
      CustomUserPreferences = {
        ".GlobalPreferences" = {
          # automatically switch to a new space when switching to the application
          AppleSpacesSwitchOnActivate = false;
        };
        NSGlobalDomain = {
          # Add a context menu item for showing the Web Inspector in web views
          WebKitDeveloperExtras = true;
        };
        "com.apple.finder" = {
          ShowExternalHardDrivesOnDesktop = false;
          ShowHardDrivesOnDesktop = false;
          ShowMountedServersOnDesktop = false;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
          # When performing a search, search the current folder by default
          FXDefaultSearchScope = "SCcf";
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.spaces" = {
          "spans-displays" = 0; # Display have seperate spaces
        };
        "com.apple.WindowManager" = {
          EnableStandardClickToShowDesktop = 0; # Click wallpaper to reveal desktop
          StandardHideDesktopIcons = 0; # Show items on desktop
          HideDesktop = 0; # Do not hide items on desktop & stage manager
          StageManagerHideWidgets = 0;
          StandardHideWidgets = 0;
        };
        "com.apple.screensaver" = {
          # Require password immediately after sleep or screen saver begins
          askForPassword = 1;
          askForPasswordDelay = 0;
        };
        "com.apple.screencapture" = {
          location = "~/Desktop";
          type = "png";
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;
      };

      loginwindow = {
        GuestEnabled = false; # disable guest user
        SHOWFULLNAME = false; # show list of users in login window
      };
    };

    # keyboard settings is not very useful on macOS
    # the most important thing is to remap option key to alt key globally,
    # but it's not supported by macOS yet.
    keyboard = {
      enableKeyMapping = true; # enable key mapping so that we can use `option` as `control`

      # NOTE: do NOT support remap capslock to both control and escape at the same time
      remapCapsLockToControl = false; # remap caps lock to control, useful for emac users
      remapCapsLockToEscape = true; # remap caps lock to escape, useful for vim users

      # swap left command and left alt
      # so it matches common keyboard layout: `ctrl | command | alt`
      #
      # disabled, caused only problems!
      swapLeftCommandAndLeftAlt = false;
    };
  };

  # Add ability to use TouchID for sudo authentication (including tmux sessions)
  # Note: Using environment.etc to create sudo_local instead of security.pam.services
  # This approach provides TouchID support in both regular terminal and tmux sessions
  environment.etc."pam.d/sudo_local".text = ''
    # Managed by Nix Darwin
    auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
    auth       sufficient     pam_tid.so
  '';

  # Auto-start applications on login
  launchd.user.agents = {
    aerospace = {
      serviceConfig = {
        ProgramArguments = [
          "/usr/bin/open"
          "-a"
          "/Applications/AeroSpace.app"
        ];
        RunAtLoad = true;
        StandardOutPath = "/tmp/aerospace.log";
        StandardErrorPath = "/tmp/aerospace.err.log";
      };
    };

    docker-desktop = {
      serviceConfig = {
        ProgramArguments = [
          "/usr/bin/open"
          "-a"
          "/Applications/Docker.app"
        ];
        RunAtLoad = true;
        StandardOutPath = "/tmp/docker-desktop.log";
        StandardErrorPath = "/tmp/docker-desktop.err.log";
      };
    };

    # Alacritty theme auto-switcher - monitors macOS appearance changes
    alacritty-theme-monitor = {
      serviceConfig = {
        ProgramArguments = [
          "/bin/bash"
          "/etc/nix-darwin/scripts/alacritty_theme_monitor.sh"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/alacritty-theme-monitor.log";
        StandardErrorPath = "/tmp/alacritty-theme-monitor.err.log";
      };
    };

    # Borders - window border manager (reads config from ~/.config/borders/bordersrc)
    borders = {
      serviceConfig = {
        ProgramArguments = ["${pkgs.jankyborders}/bin/borders"];
        RunAtLoad = true;
        KeepAlive = true;
      };
    };

    # SketchyBar - status bar (reads config from ~/.config/sketchybar/sketchybarrc)
    sketchybar = {
      serviceConfig = {
        ProgramArguments = ["${pkgs.sketchybar}/bin/sketchybar"];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/sketchybar.log";
        StandardErrorPath = "/tmp/sketchybar.err.log";
      };
    };

    # Hide sketchybar while the cursor is in the menu-bar reveal zone, so the
    # auto-hidden native macOS menu bar stays readable.
    sketchybar-menubar-watch = {
      serviceConfig = {
        ProgramArguments = [
          "/bin/bash"
          "/etc/nix-darwin/scripts/sketchybar_menubar_watch.sh"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/sketchybar-menubar-watch.log";
        StandardErrorPath = "/tmp/sketchybar-menubar-watch.err.log";
      };
    };
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  environment.shells = [
    pkgs.zsh
  ];

  # Set your time zone.
  time.timeZone = "Europe/Brussels";

  # Fonts
  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-design-icons
      font-awesome
      # Nerd Fonts (select only the ones you need)
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      nerd-fonts.symbols-only
    ];
  };
}
