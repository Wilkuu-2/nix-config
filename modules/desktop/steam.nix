{config, pkgs,lib, ...}: {
  options.addons = {
      steam.enable = lib.mkEnableOption "Enable steam on this machine"; 
  };

  config = lib.mkIf config.addons.steam.enable (lib.mkMerge [ 
    ({
      assertions = [
        { 
          assertion = config.addons.desktop.enable;
          message = "You need a desktop environment to enable Steam!"; 
        }
      ];
      programs.gamescope = {
        enable = true;
        capSysNice = false; # This needs to be false as to make nested steam stuff work in it. 
      }; 
      programs.steam = {
        enable = true; 
        # Done according to the wiki, talks about some unexpected values in a lambda? 
        # Doesn't seem to be how overrides work 
        # TODO: Figure out how overrides work
        # package = pkgs.steam.override {
        #   # withPrimus = true; 
        #   extraPackages = with pkgs; [bumblebee glxinfo];
        # }; 
        
        # Gamescope  
        gamescopeSession.enable = true;

        # Open firewall 
        remotePlay.openFirewall = true; 
        dedicatedServer.openFirewall = true; 
        localNetworkGameTransfers.openFirewall = true; 
      };

      # Enable Appimage for some steam games 
      programs.appimage.enable = true;
      programs.appimage.binfmt = true;
    }) 

    (lib.mkIf config.addons.dssktop.x11.enable {

    })
    (lib.mkIf config.addons.dssktop.wayland.enable {

    })

  ]); 
}
