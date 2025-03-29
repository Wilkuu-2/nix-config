{
   description = "Home-manager configuration"; 

   nixConfig = {
     experimental-feature = ["nix-command" "flakes"]; 
   }; 
   inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
      nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
      nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
      flake-utils.url = "github:numtide/flake-utils";
      home-manager = { 
	url = "github:nix-community/home-manager/release-24.11";
        inputs.nixpkgs.follows = "nixpkgs";
      }; 
   }; 


   
   outputs = {self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, flake-utils, home-manager, ... }@inputs: 
      let 
          inherit (self) outputs; 

	  pkgsForSystem = system: nixpkgsSource: import nixpkgsSource {
		inherit system; 
	  };
	   HomeConfiguration = args: 
		let
		   nixpkgs = args.nixpkgs or nixpkgs-stable;  
		in    
		   home-manager.lib.homeManagerConfiguration {
		   modules = [ 
			(import ./home )
			(import ./modules )
		   ];
		   extraSpecialArgs = {
			inherit (args) nixpkgs;	
		   } // args.extraSpecialArgs; 
		   pkgs = pkgsForSystem (args.system or "x86_64-linux") nixpkgs;
		};


      in flake-utils.lib.eachSystem [ 
        "x86_64-linux" 
      ] (system: {
         legacyPackages = pkgsForSystem system nixpkgs;
      }) // {
         # overlays = import ./overlays {inherit inputs;};
	 homeConfigurations = {
            "wilkuu" = HomeConfiguration  {
		extraSpecialArgs = {
		};
            	 
            }; 
         };
         inherit home-manager; 
         inherit (home-manager) packages;
      };
}
