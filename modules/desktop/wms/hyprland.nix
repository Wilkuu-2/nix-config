{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.addons.desktop.hyprland;
in
{
  options.addons.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (import ../../../utils/makeWm.nix "hyprland" "wayland")
      {
        programs.hyprland.enable = true;
        programs.hyprland.withUWSM = true;
        programs.uwsm = {
          enable = true;
          # waylandCompositors = {
          #   hyprland = {
          #     prettyName = "Hyprland";
          #     comment = "Hyprland compositor managed by UWSM";
          #     # binPath = "/run/current-system/sw/bin/Hyprland";
          #   };
          # };
        };

        environment.systemPackages = with pkgs; [
          hyprland
          hyprshot
          hypridle
          hyprpaper
          hyprpicker
          hyprnotify
          hyprcursor
          hyprpolkitagent
          wofi
          waybar
          waybar-mpris
          mako
          wl-clipboard
          hyprland-qt-support
        ];
      }
    ]
  );
}
