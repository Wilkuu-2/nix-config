{ config, lib, pkgs, modulesPath, ...}:
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
      ssh_identity = "/etc/vault_key"; # NOTE: must be readable by user/group btrbk
      ssh_user = "vaultmanager";
      stream_compress = "lz4";
      volume."/btrfs_root" = {
        target = "ssh://10.100.0.1/vault/backups/apocalypse";
        subvolume = { 
          "@root" = { 
            snapshot_create = "always";
          };  
        };
      };
    };
  };
};
}
