{ config, lib, ... }:
let
  cfg = config.hosts.omega-relay;
in 
{
  options.hosts.omega-relay = with lib; {
    root_device = mkOption {
      type = types.path; 
      default = "/dev/sda"; 
      example = "/dev/sda"; 
      description = "Root device for disko and grub";
    }; 

    do_disko = mkOption {
      type = types.bool; 
      default = !config.addons.virtualisation.isTestVM; 
      description = "Whenever to do disko or not."; 
    }; 
  };  
  config = lib.mkIf (cfg.do_disko) ({
    services.btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
    };

    boot.loader.grub.device = cfg.root_device;
    # Workaround
    boot.loader.grub.devices = lib.mkForce [ cfg.root_device ];
    boot.loader.efi.canTouchEfiVariables = false;

    # TODO: Mount points

    # Disko for formatting
    disko.devices = {
      disk = {
        main-disk = {
          device = cfg.root_device;
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
