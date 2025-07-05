{pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      hyprland
      hyprshot
      hyprkeys
      hypridle
      hyprpaper
      hyprpicker
      hyprnotify
      hyprcursor
      hyprpolkitagent
       waybar
       waybar-mpris
    ]; 


  services.xserver.exportConfiguration = true; # This makes it easy to search for a valid keymap 
  # Enable KDE6 env in case Hyprland gets borked. 
  # services.desktopManager.plasma6.enable = true;
  programs.hyprland.enable = true; 
  programs.hyprland.withUWSM  = true; 
  programs.uwsm = {
    enable = true; 
    waylandCompositors ={
      hyprland = {
        prettyName = "Hyprland";
        comment = "Hyprland compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/Hyprland";
      };
    };
  };
  
  xdg.portal = {
     enable = true;
     extraPortals = with pkgs; [ xdg-desktop-portal-hyprland xdg-desktop-portal-gtk ]; 
     config = {
         common = {
           default = [
             "hyprland"
             "gtk"
           ];
           "org.freedesktop.impl.portal.Filechooser"="gtk";
         }; 
      }; 
  };
}
