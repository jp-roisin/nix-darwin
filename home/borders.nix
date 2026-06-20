{ ... }:
{
  home.file.".config/borders/bordersrc" = {
    force = true; # overwrite existing file
    executable = true;
    text = ''
      #!/bin/bash

      options=(
        style=round
        width=8.0
        hidpi=off
        active_color=0xfffdcc60
        inactive_color=0xff414550
      )

      /opt/homebrew/opt/borders/bin/borders "''${options[@]}"
    '';
  };
}
