{pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      hyprland
      hyprgui
      hyprshot
      hyprkeys
      hypridle
      hyprpaper
      hyprpicker
      hyprnotify
      hyprcursor
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
     config = {
        common = {
          default = [
            "hyprland"
            "gtk"
          ];
        }; 
     }; 
  };
}
