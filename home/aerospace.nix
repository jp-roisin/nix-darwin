{ ... }:
{
  home.file.".config/aerospace/aerospace.toml" = {
    force = true; # overwrite existing file
    source = ./aerospace.toml;
  };
}
