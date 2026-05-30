{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    stalwart-nix = {
      # local testing
      # url = "path:/store2/code/stalwart-nix";
      url = "github:Wilkuu-2/stalwart-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # tatuin = {
    #   url = "github:Wilkuu-2/tatuin/flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    continuwuity = {
      url = "git+https://forgejo.ellis.link/continuwuation/continuwuity.git?ref=refs/tags/v0.5.9";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      disko,
      stalwart-nix,
      sops-nix,
      home-manager,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      # Allows code to execute for all used architectures
      pkgsPerSystem = (lib.genAttrs systems (system: nixpkgs.legacyPackages.${system}));
      forAllSystems = f: (lib.genAttrs systems (system: f pkgsPerSystem.${system} system));

      # Treefmt has a bunch of long paths that we want to bundle.
      treefmt = forAllSystems (pkgs: _: treefmt-nix.lib.evalModule pkgs ./modules/treefmt.nix);
    in
    {
      packages = (lib.recursiveUpdate  
        (forAllSystems (
          pkgs: _system: {
            bulwark = pkgs.callPackage ./packages/bulwark/package.nix { };
          }
        ))
        {
          "x86_64-linux".full-iso = self.nixosConfigurations.full-iso.config.system.build.isoImage;
        });

      # for `nix fmt`
      formatter = forAllSystems (_: system: treefmt.${system}.config.build.wrapper);
      # for `nix flake check`
      checks = forAllSystems (_: system: { formatting = treefmt.${system}.config.build.check self; });

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
            stalwart-nix.nixosModules.default
            home-manager.nixosModules.default
            sops-nix.nixosModules.default
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
            home-manager.nixosModules.default
            sops-nix.nixosModules.default
          ];
        };
        omega-relay = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          system = "x86_64-linux";
          modules = [
            ./modules
            ./users/wilkuu-server.nix
            ./hosts/omega-relay
            home-manager.nixosModules.default
            disko.nixosModules.disko
            sops-nix.nixosModules.default
          ];

        };
        tacitus = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          system = "x86_64-linux";
          modules = [
            ./modules
            ./users/wilkuu-server.nix
            ./hosts/tacitus
            home-manager.nixosModules.default
            disko.nixosModules.disko
            sops-nix.nixosModules.default
          ];

        };
      };
    };
}
