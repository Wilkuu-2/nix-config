{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.addons.btrfs;
in
{
  options.addons.btrfs = {
    enable = lib.mkEnableOption "Enable btrfs-related apps and utils";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
      };
    })
  ];
}
