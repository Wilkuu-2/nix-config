{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
       url = "github:nix-community/home-manager";
       inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    packages."x86_64-linux".full-iso = self.nixosConfigurations.full-iso.config.system.build.isoImage; 
    nixosConfigurations = { 
      
      apocalypse = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        system = "x86_64-linux";
        modules = [
          ./common.nix
          ./hosts/apocalypse
          ./users/wilkuu.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      test_vm = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        system = "x86_64-linux";
        modules = [
          ./common.nix
          ./hosts/test_vm
          ./users/wilkuu.nix
          inputs.home-manager.nixosModules.default
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
          ./common.nix
          ./hosts/full-iso
          ./users/live-user.nix
          inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}
