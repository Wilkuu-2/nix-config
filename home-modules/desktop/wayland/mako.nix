{pkgs, config, hostconfig, lib,...}: {
  options.homeprogs.mako.enable = lib.mkEnableOption "Enable Mako notification manager";
  config = lib.mkIf config.homeprogs.mako.enable {
    services.mako = {
      enable = true;
    };
    xdg.configFile."mako/config".source = ./mako.ini; 

  }; 


}
