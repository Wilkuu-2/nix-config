{ config, lib, pkgs, modulesPath, ...}:
{
  services.btrbk = {
  instances."remote_vault" = {
    onCalendar = "weekly";
    settings = {
      ssh_identity = "/etc/btrbk_key"; # NOTE: must be readable by user/group btrbk
      ssh_user = "vault";
      stream_compress = "lz4";
      volume."/btrfs_root" = {
        target = "ssh://10.100.0.1/vault/backups/apocalypse";
        subvolume = { 
          nixos = { 
            snapshot_create = "always";
          };  
        };
        # "nixos" could instead be an attribute set with other volumes to
        # back up and to give subvolume specific configuration.
        # See man btrbk.conf for possible options.
        /*
        subvolume = {
          home = { snapshot_create = "always"; };
          nixos = {};
        };
        */
      };
    };
  };
};
}
