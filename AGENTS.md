# Agent Guide for nix-darwin Configuration

This is a personal nix-darwin configuration repository for managing macOS system settings, packages, and applications declaratively using Nix.

## Repository Structure

```
.
├── flake.nix                 # Main flake configuration
├── flake.lock                # Flake dependency lock file
├── Makefile                  # Build commands
├── modules/                  # System-level modules
│   ├── nix-core.nix         # Nix daemon and flake settings
│   ├── system.nix           # macOS system preferences
│   ├── apps.nix             # Homebrew and system packages
│   └── host-users.nix       # Host and user configuration
├── home/                     # User-level home-manager modules
│   ├── default.nix          # Home-manager entry point
│   ├── core.nix             # Core packages and programs
│   ├── git.nix              # Git configuration
│   └── shell.nix            # Zsh shell configuration
└── scripts/                  # Helper scripts
    └── brew_no_quarantine.sh # Remove quarantine from Chromium
```

## Build Commands

### Primary Build Command
```bash
make build
```
This command:
1. Builds the darwin configuration: `nix build .#darwinConfigurations.macbook.system`
2. Switches to the new configuration: `./result/sw/bin/darwin-rebuild switch --flake .#macbook`
3. Removes quarantine from Chromium: `./scripts/brew_no_quarantine.sh`

### Manual Build Steps
```bash
# Build the configuration
nix build .#darwinConfigurations.macbook.system --extra-experimental-features 'nix-command flakes'

# Switch to the new configuration
./result/sw/bin/darwin-rebuild switch --flake .#macbook

# Or use darwin-rebuild directly (if already installed)
darwin-rebuild switch --flake .#macbook
```

### Format Nix Code
```bash
nix fmt
```
Uses `alejandra` formatter (configured in flake.nix:86).

### Update Flake Dependencies
```bash
nix flake update
```

## Code Style Guidelines

### Nix Language

#### File Structure
- **Module Entry Point**: Always use `{ pkgs, ... }:` or `{ lib, ... }:` parameter pattern
- **Module Returns**: Return an attribute set containing configuration options
- **Imports**: Place at the top of the module in an `imports` list

#### Formatting
- **Indentation**: 2 spaces (no tabs)
- **Line Length**: No strict limit, but keep lines readable (typically under 120 chars)
- **Lists**: Align items vertically, one per line for multi-item lists
- **Attribute Sets**: Use multi-line format with proper indentation
- **Semicolons**: Required at the end of expressions

#### Example Module Structure
```nix
{ pkgs, lib, ... }:
{
  # Imports first
  imports = [
    ./other-module.nix
  ];

  # Configuration options
  programs.example = {
    enable = true;
    setting = "value";
  };

  # Lists formatted vertically
  environment.systemPackages = with pkgs; [
    package1
    package2
    package3
  ];
}
```

### Naming Conventions

#### Files
- **Kebab-case**: `nix-core.nix`, `host-users.nix`
- **Module names**: Descriptive and specific to their purpose
- **Default imports**: Use `default.nix` as the entry point for directories

#### Variables and Attributes
- **camelCase**: For local variables and let bindings
- **kebab-case**: For attribute names following nix-darwin conventions
- **UPPER_CASE**: For environment variables in shell configurations

#### Configuration Keys
Follow upstream conventions:
- nix-darwin options: Use official names from documentation
- home-manager options: Use official names from home-manager docs
- Custom attributes: Use camelCase for consistency

### Comments

#### When to Comment
- **Complex logic**: Explain why, not what
- **Disabled options**: Explain why commented out
- **Non-obvious settings**: Document purpose and expected behavior
- **External links**: Reference documentation or discussions

#### Comment Style
```nix
# Single line comments use hash

# Multi-line explanations should be
# broken across multiple lines with
# each line starting with a hash

##########################################################################
#
#  Section headers can use multiple hashes for visibility
#
##########################################################################
```

### Imports and Dependencies

#### Import Order
1. Home-manager or system modules (./module.nix)
2. External packages (pkgs)
3. External libraries (lib)

#### With Statements
```nix
# Acceptable for packages
environment.systemPackages = with pkgs; [
  git
  neovim
];

# Avoid nested with statements
# Keep scope clear and limited
```

### Error Handling

#### Assertions
Use assertions for critical requirements:
```nix
{
  assertions = [{
    assertion = condition;
    message = "Clear error message explaining the requirement";
  }];
}
```

#### Warnings
Use warnings for deprecations or suggestions:
```nix
{
  warnings = [
    "Deprecated: Use newOption instead of oldOption"
  ];
}
```

## Configuration Management

### User-Specific Settings
- Username: `jp` (defined in flake.nix:56)
- Email: `jeanpaul.roisin@protonmail.com` (defined in flake.nix:57)
- Hostname: `macbook` (defined in flake.nix:59)
- System: `aarch64-darwin` (Apple Silicon)

### Adding Packages
- **Nix packages**: Add to `modules/apps.nix` (environment.systemPackages)
- **User packages**: Add to `home/core.nix` (home.packages)
- **Homebrew formulae**: Add to `modules/apps.nix` (homebrew.brews)
- **Homebrew casks**: Add to `modules/apps.nix` (homebrew.casks)

### Modifying System Settings
- **macOS defaults**: Edit `modules/system.nix` (system.defaults)
- **Keyboard/trackpad**: Edit `modules/system.nix` (keyboard/trackpad sections)
- **Shell configuration**: Edit `home/shell.nix`
- **Git settings**: Edit `home/git.nix`

## Testing Changes

1. **Test build**: `make build` or `nix build .#darwinConfigurations.macbook.system`
2. **Check for errors**: Fix any build errors before applying
3. **Apply configuration**: `darwin-rebuild switch --flake .#macbook`
4. **Verify changes**: Check that settings/packages are correctly applied
5. **Rollback if needed**: `darwin-rebuild --rollback`

## Best Practices

1. **Incremental changes**: Make small, focused changes and test frequently
2. **Commit regularly**: Use git to track configuration changes
3. **Comment non-obvious settings**: Explain why, not what
4. **Keep modules focused**: Each module should have a single responsibility
5. **Use upstream defaults**: Only override when necessary
6. **Document custom scripts**: Add comments explaining purpose and usage
7. **Test after updates**: Always test after `nix flake update`
8. **Backup important data**: Before major system configuration changes

## Common Tasks

### Update a specific package
```bash
nix flake lock --update-input nixpkgs-darwin
nix flake lock --update-input home-manager
```

### Check what will change
```bash
darwin-rebuild build --flake .#macbook
nix store diff-closures /run/current-system ./result
```

### List installed packages
```bash
nix-env -q
darwin-rebuild --list-generations
```

## References

- [nix-darwin manual](https://daiderd.com/nix-darwin/manual/index.html)
- [home-manager manual](https://nix-community.github.io/home-manager/)
- [Nix language documentation](https://nixos.org/manual/nix/stable/language/)
- [NixOS and Flakes Book](https://github.com/ryan4yin/nixos-and-flakes-book)
- [macOS defaults reference](https://github.com/yannbertrand/macos-defaults)
