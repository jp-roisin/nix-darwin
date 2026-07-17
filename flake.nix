{
  description = "Nix for macOS configuration";

  inputs = {
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # herdr — terminal workspace manager for AI coding agents
    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # openspec — AI-native spec-driven development CLI
    openspec = {
      url = "github:Fission-AI/OpenSpec";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # pi — coding agent (no official flake; community-maintained)
    pi = {
      url = "github:lukasl-dev/pi.nix";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs-darwin,
      darwin,
      home-manager,
      ...
    }:
    let
      # Shared across all machines; only the hostname differs.
      username = "jp";
      useremail = "72938245+jp-roisin@users.noreply.github.com";
      system = "aarch64-darwin";
      hostnames = [
        "macbook"
        "macbook-pro-m5"
      ];

      # Generate configurations for all machines dynamically
      darwinConfigurations = builtins.listToAttrs (
        map (hostname: {
          name = hostname;
          value = darwin.lib.darwinSystem {
            inherit system;
            specialArgs = inputs // {
              inherit username useremail hostname;
            };
            modules = [
              ./modules/nix-core.nix
              ./modules/system.nix
              ./modules/apps.nix
              ./modules/host-users.nix

              # home manager
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = inputs // {
                  inherit username useremail hostname;
                };
                home-manager.users.${username} = import ./home/default.nix;
              }
            ];
          };
        }) hostnames
      );
    in
    {
      inherit darwinConfigurations;
      # nix code formatter
      formatter."aarch64-darwin" = nixpkgs-darwin.legacyPackages."aarch64-darwin".alejandra;
    };
}
