{
  description = "Nix for macOS configuration";

  ##################################################################################################################
  #
  # Want to know Nix in details? Looking for a beginner-friendly tutorial?
  # Check out https://github.com/ryan4yin/nixos-and-flakes-book !
  #
  ##################################################################################################################

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";

    # home-manager, used for managing user configuration
    home-manager = {
      # url = "github:nix-community/home-manager/release-24.05";
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
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
  };

  # The `outputs` function will return all the build results of the flake.
  # A flake can have many use cases and different types of outputs,
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # However, `self` is an exception, this special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
  outputs =
    inputs@{
      self,
      nixpkgs,
      darwin,
      home-manager,
      ...
    }:
    let
      # Define all machines with their specific configurations
      machines = {
        macbook = {
          username = "jp";
          useremail = "72938245+jp-roisin@users.noreply.github.com";
          system = "aarch64-darwin";
          hostname = "macbook";
        };
        "macbook-pro-m5" = {
          username = "jp";
          useremail = "72938245+jp-roisin@users.noreply.github.com";
          system = "aarch64-darwin";
          hostname = "macbook-pro-m5";
        };
      };

      # Generate configurations for all machines dynamically
      darwinConfigurations = builtins.listToAttrs (
        map (machineName: {
          name = machineName;
          value = darwin.lib.darwinSystem {
            system = machines.${machineName}.system;
            specialArgs = inputs // {
              inherit (machines.${machineName}) username useremail hostname;
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
                  inherit (machines.${machineName}) username useremail hostname;
                };
                home-manager.users.${machines.${machineName}.username} = import ./home/default.nix;
              }
            ];
          };
        }) (builtins.attrNames machines)
      );
    in
    {
      inherit darwinConfigurations;
      # nix code formatter
      formatter."aarch64-darwin" = nixpkgs.legacyPackages."aarch64-darwin".alejandra;
    };
}
