{ config, lib, ... }:
let
  cfg = config.wilkuu.services.uptimekuma;
  hostname = config.networking.hostName;
in
{
  options.wilkuu.services.uptimekuma = with lib; {
    domain = mkOption {
      type = types.str;
      default = "uptime.${hostname}.local";
      example = "uptime.wilkuu.xyz";
      description = "Domain for http connections.";
    };
    doACME = mkEnableOption "Enable ACME for uptime kuma here";
    enable = mkEnableOption "Enable the uptime-kuma service";
    dataDir = mkOption {
      type = types.path;
      description = "Storage localtion for uptime kuma data, currently ignored, because nixpkgs sucks";
      default = "/srv/data/uptimekuma";
      example = "/srv/data/uptimekuma";
    };
  };

  config = lib.mkIf cfg.enable ({
    networking.hosts = {
      "127.0.0.1" = [ cfg.domain ];
    };

    users.users.uptimekuma = {
      isSystemUser = true;
      group = "uptimekuma";
    };
    users.groups.uptimekuma = { };

    systemd.services.uptime-kuma.serviceConfig.User = "uptimekuma";
    systemd.services.uptime-kuma.after = [ "mysql.service" ];

    # sops.secrets =
    #   (lib.genAttrs (map toSops secrets)
    #     (name: {
    #       sopsFile = sopsPath;
    #       mode = "0440";
    #       owner = "uptime-kuma";
    #     }));

    services.nginx.virtualHosts."${cfg.domain}" = {
      addSSL = cfg.doACME;
      enableACME = cfg.doACME;
      locations."/" = {
        proxyPass = "http://localhost:3111";
        recommendedProxySettings = true;
      };
    };

    wilkuu.services.mysql =
      let
        user = config.systemd.services.uptime-kuma.serviceConfig.User;
      in
      {
        unix_users = [ user ];
        databases.uptimekuma = {
          enable = true;
          allowedUsers = [ user ];
        };
      };

    services.uptime-kuma = {
      enable = true;
      settings = {
        UPTIME_KUMA_PORT = "3111";
        UPTIME_KUMA_HOST = "127.0.0.1";
        UPTIME_KUMA_DB_TYPE = "sqlite";
        #UPTIME_KUMA_DB_SOCKET   = "/run/mysqld/mysqld.sock";
        #UPTIME_KUMA_DB_USERNAME = config.systemd.services.uptime-kuma.serviceConfig.User;
        #UPTIME_KUMA_DB_NAME     = "uptimekuma";
      };
    };
  });
}
