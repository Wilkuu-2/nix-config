{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    btrbk
    lz4
  ];

  services.btrbk = {
    extraPackages = with pkgs; [ lz4 ];
    instances."remote_vault" = {
      onCalendar = "weekly";
      settings = {
        snapshot_preserve_min = "1w";
        snapshot_preserve = "2w";
        target_preserve_min = "1w";
        target_preserve = "4w";
        ssh_identity = "/etc/vault_key"; # NOTE: must be readable by user/group btrbk
        ssh_user = "vaultmanager";
        stream_compress = "lz4";
        volume."/btrfs_root" = {
          target = "ssh://10.127.9.1/vault/backups/apocalypse";
          subvolume = {
            "@root" = {
              snapshot_create = "ondemand";
            };
          };
        };
      };
    };
  };
}
