{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.addons.desktop.xfce;
in
{

  options.addons.desktop.xfce = {
    enable = lib.mkEnableOption "Enable xfce";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (import ../../../utils/makeWm.nix "xfce" "x11")
      {
        environment.systemPackages = with pkgs; [
          # XFCE stuff
          catfish
          xfce4-appfinder
          xfce4-clipman-plugin
          xfce4-cpugraph-plugin
          xfce4-dict
          xfce4-fsguard-plugin
          xfce4-genmon-plugin
          xfce4-netload-plugin
          xfce4-panel
          xfce4-pulseaudio-plugin
          xfce4-systemload-plugin
          xfce4-weather-plugin
          xfce4-whiskermenu-plugin
          xfce4-xkb-plugin
          xfdashboard

          # GNOME stuff
          file-roller
          gnome-disk-utility
        ];
        services.xserver.desktopManager.xfce.enable = true;
      }
    ]
  );
}
