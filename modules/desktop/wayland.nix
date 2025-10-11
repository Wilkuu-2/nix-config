{pkgs, lib, config, ...}: {
  options.addons.desktop.wayland.enable = lib.mkEnableOption "Enable wayland" ;
  config = lib.mkIf config.addons.desktop.wayland.enable {
    services.displayManager.sddm.wayland.enable = true;

    xdg.portal = { 
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk 
      ];
    };
  };
}
