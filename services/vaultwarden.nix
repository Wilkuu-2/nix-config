{ config, lib, ... }:
let
  cfg = config.wilkuu.services.vaultwarden;
  hostname = config.networking.hostName;
in
{
  options.wilkuu.services.vaultwarden = with lib; {
    domain = mkOption {
      type = types.str;
      default = "bitwarden.${hostname}.local";
      example = "bitwarden.wilkuu.xyz";
      description = "Domain for http connections.";
    };
    doACME = mkEnableOption "Enable ACME for vaultwarden here";
    enable = mkEnableOption "Enable the vaultwarden service";
    backupDir = mkOption {
      type = types.path;
      description = "Storage localtion for Vaultwarden user data backup";
      default = "/srv/data/vaultwarden";
      example = "/srv/data/vaultwarden";
    };
    signupWhitelist = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "wilkuu.xyz" ];
      description = "Domains that can sign up on vaultwarden";
    };
  };

  config = lib.mkIf cfg.enable (
    let
      sopsPath = ../secrets/${hostname}/vaultwarden.yaml;
      secrets = [ "admin_token" ];
      toSops = (sname: "vaultwarden/${sname}");
    in
    {
      networking.hosts = {
        "127.0.0.1" = [ cfg.domain ];
      };

      sops.secrets = (
        lib.genAttrs (map toSops secrets) (_name: {
          sopsFile = sopsPath;
          mode = "0440";
          owner = "vaultwarden";
        })
      );

      sops.templates.vaultwardenEnvFile.content = ''
        ADMIN_TOKEN=${config.sops.placeholder."vaultwarden/admin_token"}
      '';

      services.nginx.virtualHosts."${cfg.domain}" = {
        enableACME = cfg.doACME;
        addSSL = cfg.doACME;
        locations."/" = {
          proxyPass = "http://localhost:3222";
          recommendedProxySettings = true;
        };
      };

      services.vaultwarden = {
        enable = cfg.enable;
        # backupDir = cfg.backupDir;
        config = {
          DOMAIN = "${if cfg.doACME then "https" else "http"}://${cfg.domain}";
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = "3222";
          SIGNUPS_DOMAINS_WHITELIST = (lib.concatStringsSep "," cfg.signupWhitelist);
          SIGNUPS_ALLOWED = "false";
          IP_HEADER = "X-Forwarded-For";
        };
        environmentFile = config.sops.templates.vaultwardenEnvFile.path;
      };

    }
  );
}
