{pkgs, config, lib, ...}:
let 
  cfg = config.addons.desktop.xfce; 
in {
  
  options.addons.desktop.xfce = {
    enable = lib.mkEnableOption "Enable xfce";
  };
  
  config = lib.mkIf cfg.enable (lib.mkMerge [ 
  (import ../../../utils/makeWm.nix "xfce" "x11" )
  {
   environment.systemPackages = with pkgs; [
     # XFCE stuff
     xfce.catfish
     xfce.xfce4-appfinder
     xfce.xfce4-clipman-plugin
     xfce.xfce4-cpugraph-plugin
     xfce.xfce4-dict
     xfce.xfce4-fsguard-plugin
     xfce.xfce4-genmon-plugin
     xfce.xfce4-netload-plugin
     xfce.xfce4-panel
     xfce.xfce4-pulseaudio-plugin
     xfce.xfce4-systemload-plugin
     xfce.xfce4-weather-plugin
     xfce.xfce4-whiskermenu-plugin
     xfce.xfce4-xkb-plugin
     xfce.xfdashboard
          
     # GNOME stuff 
     file-roller
     gnome-disk-utility
   ];
   services.xserver.desktopManager.xfce.enable = true; 
  }]);
}
