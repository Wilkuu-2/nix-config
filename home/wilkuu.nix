{ config ,pkgs, hostconfig, ... }: {
   imports = [../home-modules];

   homeapps.presets.full.enable = true; 
   # homeapps.vnc = true; 

   services.wayvnc = { 
    enable = true; 
    autoStart = false; 
    settings = {
      # Todo, bind to vpn and LAN explicitly somehow
      address = "0.0.0.0";
      port = 5900; 
    };
   };
     
   homesv.vdirsyncer.enable = true;

   home.username = "wilkuu";
   home.homeDirectory = "/home/wilkuu";
   home.stateVersion = "24.11"; 
   programs.home-manager.enable = true; 
}
