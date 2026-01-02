{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tatuin = {
      url = "github:Wilkuu-2/tatuin/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: (lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system}));
      treefmtEval = forAllSystems (pkgs: treefmt-nix.lib.evalModule pkgs ./modules/treefmt.nix);
    in
    {
      # packages."x86_64-linux".full-iso = self.nixosConfigurations.full-iso.config.system.build.isoImage;
      packages = (
        forAllSystems (_pkgs: {

        })
      );
      # for `nix fmt`
      formatter = (
        forAllSystems (pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper)
      );
      # for `nix flake check`
      checks = (
        forAllSystems (pkgs: {
          formatting = treefmtEval.${pkgs.system}.config.build.check self;
        })
      );

      nixosConfigurations = {
        apocalypse = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          system = "x86_64-linux";
          modules = [
            ./modules
            ./hosts/apocalypse
            ./users/wilkuu.nix
            inputs.home-manager.nixosModules.default
            inputs.sops-nix.nixosModules.sops
          ];
        };
        full-iso = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            isoImage.squashfsCompression = "lz4";
            isoImage.isoLabel = "NIX_WQ_ISO";
          };
          system = "x86_64-linux";
          modules = [
            ./modules
            ./hosts/full-iso
            ./users/live-user.nix
            inputs.home-manager.nixosModules.default
            inputs.sops-nix.nixosModules.sops
          ];
        };
        vm-desktop = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          system = "x86_64-linux";
          modules = [
            ./modules
            ./hosts/test_vm
            ./users/live-user.nix
            inputs.home-manager.nixosModules.default
            inputs.sops-nix.nixosModules.sops
          ];
        };
        omega-relay = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs; 
          };
          system = "x86_64-linux";
          modules = [
            ./modules
            ./hosts/omega-relay
            ./users/wilkuu-server.nix
            inputs.home-manager.nixosModules.default
            inputs.sops-nix.nixosModules.sops.nix
          ]; 

        }; 
        vm-shell = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          system = "x86_64-linux";
          modules = [
            ./modules
            ./hosts/test_vm
            ./users/live-user.nix
            (
              { lib, ... }:
              {
                addons.desktop.hyprland.enable = lib.mkForce false;
                addons.desktop.xfce.enable = lib.mkForce false;
              }
            )
            inputs.home-manager.nixosModules.default
            inputs.sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
