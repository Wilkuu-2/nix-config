{ config, lib, ... }:
let
  cfg = config.addons.remote_builder;
in
{
  options.addons.remote_builder = {
    enable = lib.mkEnableOption "Enable remote builder support";
    allowedKeyFiles = lib.mkOption {
      default = [ ];
      example = [ ../secrets/example.pub ];
      description = "Public key files that are allowed on the remote builder";
    };
    allowedKeys = lib.mkOption {
      default = [ ];
      example = [ "ssh-ed25519 ... user@example.com" ];
      description = "Public keys that are allowed on the remote builder";
    };
    emulatedSystems = lib.mkOption {
      default = [ ];
      example = [ "aarch64-linux" ]; # TODO: This probably has a nice type that could be used
      description = "Allow the remote builder to emultate builds for certain architectures";
    };
    openFirewall = lib.mkEnableOption "Forces the ssh port open for the remote builder";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        users.users.remotebuild = {
          isSystemUser = true;
          group = "remotebuild";
          useDefaultShell = true;
          # Add keys to remotebuild user.
          openssh.authorizedKeys = {
            keyFiles = cfg.allowedKeyFiles;
            keys = cfg.allowedKeys;
          };
        };

        users.groups.remotebuild = { };
        nix = {
          nrBuildUsers = 64;
          settings = {
            trusted-users = [ "remotebuild" ];

            min-free = 10 * 1024 * 1024;
            max-free = 200 * 1024 * 1024;

            max-jobs = "auto";
            cores = 8;
          };
        };

        boot.binfmt.emulatedSystems = cfg.emulatedSystems;

        # TODO: Make a good default module for ssh.
        services.openssh = {
          enable = true;
          settings.AllowUsers = [ "remotebuild" ];
        };
      }

      # Open firewall for ssh if not open already, not really recommended unless the server is meant to be public.
      (lib.mkIf cfg.openFirewall {
        services.openssh.openFirewall = lib.mkForce true;
      })
    ]
  );

}
