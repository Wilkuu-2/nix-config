{ config, lib, ... }:
let
  cfg = config.addons.desktop.cosmic;
in
{
  options.addons.desktop.cosmic = {
    enable = lib.mkEnableOption "Enable Cosmic WM";
    enableScheduler = lib.mkEnableOption "Enable the special scheduler from system76";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (import ../../../utils/makeWm.nix "Cosmic WM" "wayland")
      {
        services.desktopManager.cosmic.enable = true;
        services.system76-scheduler.enable = cfg.enableScheduler;
      }
    ]
  );
}
