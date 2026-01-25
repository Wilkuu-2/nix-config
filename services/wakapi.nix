{ config, lib, ... }:
let
  cfg = config.wilkuu.services.wakapi;
  hostname = config.networking.hostName;
  service_user = config.systemd.services.wakapi.serviceConfig.User;
in
{
  options.wilkuu.services.wakapi = with lib; {
    domain = mkOption {
      type = types.str;
      default = "wakapi.${hostname}.local";
      example = "wakapi.wilkuu.xyz";
      description = "Domain for http connections.";
    };
    email = mkOption {
      type = types.str;
      default = "wakapi@${hostname}.local";
      example = "noreply@wilkuu.xyz";
      description = "Mailer address";
    };
    doACME = mkEnableOption "Enable ACME for wakapi here";
    enable = mkEnableOption "Enable the wakapi service";
    dataDir = mkOption {
      type = types.path;
      description = "Storage localtion for wakapi data";
      default = "/srv/data/wakapi";
      example = "/srv/data/wakapi";
    };
  };

  config = lib.mkIf cfg.enable (
    let
      sopsPath = ../secrets/${hostname}/wakapi.yaml;
      secrets = [ "password_salt" ];
      toSops = (sname: "wakapi/${sname}");
    in
    {
      networking.hosts = {
        "127.0.0.1" = [ cfg.domain ];
      };

      sops.secrets = (
        lib.genAttrs (map toSops secrets) (_name: {
          sopsFile = sopsPath;
          mode = "0440";
          owner = service_user;
        })
      );

      services.nginx.virtualHosts."${cfg.domain}" = {
        enableACME = cfg.doACME;
        addSSL = cfg.doACME;
        locations."/" = {
          proxyPass = "http://localhost:3111";
          recommendedProxySettings = true;
        };
      };

      wilkuu.services.mysql = {
        unix_users = [ service_user ];
        databases.wakapi = {
          enable = true;
          allowedUsers = [ service_user ];
        };
      };

      systemd.services.wakapi.after = ["mysql.service"];
      services.wakapi = {
        enable = true;
        stateDir = cfg.dataDir;
        passwordSaltFile = config.sops.secrets."wakapi/password_salt".path;
        settings = {
          server = {
            port = 3111;
            public_url = cfg.domain;
          };
          app = {
            leaderboard_enabled = false;
            leaderboard_require_auth = true;
            inactive_days = 7; # time of previous days within a user must have logged in to be considered active
            # go time format strings to format human-readable dates
            # for details, check https://pkg.go.dev/time#Time.Format
            date_format = "Mon, 02 Jan 2006";
            datetime_format = "Mon, 02 Jan 2006 15:04";
          };
          db = {
            socket = "/run/mysqld/mysqld.sock";
            name = "wakapi";
            dialect = "mysql";
          };
          security = {
            insecure_cookies = false;
            trust_reverse_proxy_ips = "127.0.0.1";
          };
          mail = {
            # FIXME: Add email
            enabled = false;
            provider = "smtp";
            sender = "<Wakapi ${cfg.email}>";
            smtp = {
            };
          };
        };
        database = {
          dialect = "mysql";
          createLocally = false;
        };

      };
    }
  );
}
