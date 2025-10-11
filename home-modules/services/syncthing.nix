{ config, pkgs, lib ,... }:
{
  config = lib.mkIf config.homeapps.presets.connectivity.enable  {  
    services.syncthing = {
      enable = true; 
    };
  };  
}

