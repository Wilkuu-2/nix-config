{ config, lib, ... }:
{
  options.host-config.disko = with lib; {
    root_device = mkOption {
      type = types.path;
      default = "/dev/nvme0n1";
      example = "/dev/nvme0n1";
      description = "Root device for disko and grub";
    };
    enable = mkOption {
      type = types.bool;
      default = !config.addons.virtualisation.isTestVM;
      description = "Whenever to enable disko or not.";
    };
  };

  config =
    let
      cfg = config.host-config.disko;
    in
    lib.mkIf (cfg.enable) {
      services.btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
      };

      disko.devices = {
        disk = {
          main-disk = {
            device = cfg.root_device;
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  type = "EF00";
                  size = "512M";
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
                    type = "btrfs";
                    extraArgs = [ "-f" ];
                    subvolumes = {
                      # Subvolume name is different from mountpoint
                      "/rootfs" = {
                        mountOptions = [ "compress=zstd" ];
                        mountpoint = "/";
                      };
                      # Subvolume name is the same as the mountpoint
                      "/home" = {
                        mountOptions = [ "compress=zstd" ];
                        mountpoint = "/home";
                      };
                      # Parent is not mounted so the mountpoint must be set
                      "/nix" = {
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                        mountpoint = "/nix";
                      };
                      # Subvolume for the swapfile
                      "/swap" = {
                        mountpoint = "/.swapvol";
                        swap = {
                          swapfile.size = "8G";
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
}
