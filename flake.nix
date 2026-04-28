{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

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
      url = "github:continuwuity/continuwuity?tag=5.7.0";
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
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      # Allows code to execute for all used architectures
      forAllSystems = f: (lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system}));

      # Treefmt has a bunch of long paths that we want to bundle.
      treefmtStuff = forAllSystems (
        pkgs:
        let
          treefmt = treefmt-nix.lib.evalModule pkgs ./modules/treefmt.nix;
        in
        {
          formatter = treefmt.config.build.wrapper;
          formatCheck = {
            formatting = treefmt.config.build.check self;
          };
        }
      );
      # Convenient extractor which generates an attrset of system: attribute, with the attribute being picked from treefmtStuff by name.
      treefmtExtract = name: (builtins.mapAttrs (_system: conf: conf."${name}") (treefmtStuff));
    in
    {
      packages."x86_64-linux".full-iso = self.nixosConfigurations.full-iso.config.system.build.isoImage;
      # for `nix fmt`
      formatter = treefmtExtract "formatter";
      # for `nix flake check`
      checks = treefmtExtract "formatCheck";

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
        omega-relay = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          system = "x86_64-linux";
          modules = [
            ./modules
            ./users/wilkuu-server.nix
            ./hosts/omega-relay
            inputs.home-manager.nixosModules.default
            disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
          ];

        };
      };
    };
}
