{pkgs, ...}: {
  imports = [ 
  	#./hyprland.nix 
	#./syncthing.nix 
	./theming.nix 
	#./neovim.nix 
	#./xdg.nix
   ];

   nixpkgs.config.allowUnfree = true;
   

   home.username = "wilkuu";
   home.homeDirectory = "/home/wilkuu";
   home.stateVersion = "24.11"; 
   programs.home-manager.enable = true; 
}
