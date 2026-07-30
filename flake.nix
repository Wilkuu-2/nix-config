{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    stalwart-nix = {
      # local testing
      # url = "path:/store2/code/stalwart-nix";
      url = "github:Wilkuu-2/stalwart-nix";
      # Letting stalwart-nix using it's own nixpkgs prevents unnecessary rebuilds at the cost of some disk space.
      # inputs.nixpkgs.follows = "nixpkgs";
      # inputs.treefmt-nix.follows = "treefmt-nix";
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
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      disko,
      sops-nix,
      home-manager,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      inventory = (import ./inventory.nix) { inherit inputs; };
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
      packages = (
        lib.recursiveUpdate
          (forAllSystems (
            pkgs: _system: {
              bulwark = pkgs.callPackage ./packages/bulwark/package.nix { };
            }
          ))
          {
            # "x86_64-linux".full-iso = self.nixosConfigurations.full-iso.config.system.build.isoImage;
          }
      );

      # for `nix fmt`
      formatter = forAllSystems (_: system: treefmt.${system}.config.build.wrapper);
      # for `nix flake check`
      checks = forAllSystems (_: system: { formatting = treefmt.${system}.config.build.check self; });

      nixosConfigurations = lib.mapAttrs (
        self_name: host:
        lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit inventory;
            inherit self_name;
          };
          inherit (host) system;
          modules = [
            ./modules
            ./hosts/${self_name}
            home-manager.nixosModules.default
            sops-nix.nixosModules.default
            disko.nixosModules.disko
          ]
          ++ host.nix-modules;
        }
      ) (lib.filterAttrs (_n: h: (h.nix && h.type != "live")) inventory);
    };
}
