{ config ,pkgs, ... }: {
   imports = [../home-modules];

   homeapps.presets.full.enable = true; 
     

   home.username = "wilkuu";
   home.homeDirectory = "/home/wilkuu";
   home.stateVersion = "24.11"; 
   programs.home-manager.enable = true; 
}
