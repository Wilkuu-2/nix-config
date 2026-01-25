{ config, lib, ... }:
{
  config = lib.mkIf (!config.addons.virtualisation.isTestVM) ({
    services.btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
    };

    boot.loader.grub.device = "/dev/sda";
    # Workaround
    boot.loader.grub.devices = lib.mkForce [ "/dev/sda" ];
    boot.loader.efi.canTouchEfiVariables = false;

    # TODO: Mount points

    # Disko for formatting
    disko.devices = {
      disk = {
        main-disk = {
          device = "/dev/sda";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              BOOT = {
                type = "EF02";
                size = "1M";
              };
              ESP = {
                type = "EF00";
                size = "128M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "btrfs";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  });
}
