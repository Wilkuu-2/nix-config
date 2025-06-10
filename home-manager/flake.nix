{
  description = "Home-manager configuration";

  nixConfig = {
    experimental-feature = [
      "nix-command"
      "flakes"
    ];
  };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    iamb.url = "github:ulyssa/iamb";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in {
    homeConfigurations = {
      "wilkuu" = home-manager.lib.homeManagerConfiguration {
        modules = [
          (import ./home)
          (import ./modules)
        ];
        # TODO: Figure out how to ship on other platforms in case you want to use a NixOS Pi, or a 32bit machine
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
      };
    };
  };
}
