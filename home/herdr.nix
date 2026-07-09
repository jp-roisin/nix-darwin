{ ... }:
{
  home.file.".config/herdr/config.toml" = {
    force = true; # overwrite existing file
    source = ./herdr.toml;
  };
}
