{ ... }:
{
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
}
