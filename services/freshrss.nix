{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wilkuu.services.freshrss;
  hostname = config.networking.hostName;
in
{

  options.wilkuu.services.freshrss = with lib; {
    domain = mkOption {
      type = types.str;
      default = "rss.${hostname}.local";
      example = "rss.wilkuu.xyz";
      description = "Domain for http connections.";
    };
    doACME = mkEnableOption "Enable ACME for fresh-rss here";
    enable = mkEnableOption "Enable the fresh-rss service";
    dataDir = mkOption {
      type = types.path;
      description = "Storage localtion for fresh-rss data";
      default = "/srv/data/freshrss";
      example = "/srv/data/freshrss";
    };
  };

  config = lib.mkIf cfg.enable (
    let
      sopsPath = ../secrets/${hostname}/freshrss.yaml;
      secrets = [
        "admin_password"
        "db_pass"
      ];
      toSops = (sname: "fresh-rss/${sname}");
    in
    {
      networking.hosts = {
        "127.0.0.1" = [ cfg.domain ];
      };

      sops.secrets = (
        lib.genAttrs (map toSops secrets) (_name: {
          sopsFile = sopsPath;
          mode = "0440";
          owner = config.services.freshrss.user;
        })
      );

      services.nginx.virtualHosts."${cfg.domain}" = {
        addSSL = cfg.doACME;
        enableACME = cfg.doACME;
      };

      wilkuu.services.mysql = {
        enable = true;
        users."freshrss" = {
          sopsPlaceholder = config.sops.placeholder."fresh-rss/db_pass";
        };
        databases."freshrss" = {
          enable = true;
          allowedUsers = [ "freshrss" ];
        };
      };

      services.freshrss = {
        enable = true;
        # api.enable = true;
        dataDir = cfg.dataDir;
        baseUrl = "https://${cfg.domain}";
        extensions = with pkgs.freshrss-extensions; [
          youtube
          title-wrap
          auto-ttl
          reading-time
        ];
        passwordFile = config.sops.secrets."fresh-rss/admin_password".path;
        virtualHost = cfg.domain;
        database = {
          passFile = config.sops.secrets."fresh-rss/db_pass".path;
          host = "localhost";
          port = config.wilkuu.services.mysql.port;
          name = "freshrss";
          user = "freshrss";
          type = "mysql";
        };
      };
    }
  );
}
