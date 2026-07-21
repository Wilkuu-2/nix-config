{ config, lib, ... }:
let
  cfg = config.wilkuu.services.firefly-iii;
  inherit (lib)
    types
    mkOption
    mkEnableOption
    mkIf
    ;
in
{
  options.wilkuu.services.firefly-iii = {
    enable = mkEnableOption "firefly III";
    enable-importer = mkEnableOption "firefly III data importer";
    domain = mkOption {
      type = types.str;
      description = "domain";
      default = "fin.${config.networking.hostName}.local";
      example = "fin.wilkuu.xyz";
    };
    importer-domain = mkOption {
      type = types.str;
      description = "domain for the importer";
      default = "fin-imp.${config.networking.hostName}.local";
      example = "fin-imp.wilkuu.xyz";
    };

  };
  config = mkIf cfg.enable {
    services.nginx.virtualHosts = {
      ${cfg.domain} = {
        enableACME = lib.mkForce false;
        addSSL = lib.mkForce false;
        forceSSL = lib.mkForce false;
      };
      ${cfg.importer-domain} = {
        enableACME = lib.mkForce false;
        addSSL = lib.mkForce false;
        forceSSL = lib.mkForce false;
      };
    };
    users.users."firefly_iii" = {
      isSystemUser = true;
      group = "firefly_iii";
    };
    users.groups."firefly_iii" = { };
    sops.secrets =
      lib.genAttrs
        [
          "firefly_iii/app_key"
          "firefly_iii/email_password"
          "firefly_iii/email_username"
          "firefly_iii/db_password"
        ]
        (_: {
          sopsFile = ../secrets/${config.networking.hostName}/firefly_iii.yaml;
          owner = "firefly_iii";
        });
    wilkuu.services.mysql = {
      enable = true;
      databases."firefly_iii" = {
        enable = true;
        allowedUsers = [ "firefly_iii" ];
      };
      users.firefly_iii = {
        sopsPlaceholder = config.sops.placeholder."firefly_iii/db_password";
        host = "localhost";
      };
    };
    services.firefly-iii = {
      enableNginx = true;
      virtualHost = cfg.domain;
      enable = true;
      user = "firefly_iii";
      group = "nginx";
      settings = {
        APP_KEY_FILE = config.sops.secrets."firefly_iii/app_key".path;
        APP_URL = "https://${cfg.domain}";

        # DB
        DB_CONNECTION = "mysql";
        DB_DATABASE = "firefly_iii";
        DB_HOST = "localhost";
        DB_PORT = config.services.mysql.settings.mysqld.port;
        DB_USERNAME = "firefly_iii";
        DB_PASSWORD = config.sops.secrets."firefly_iii/db_password".path;

        # Proxying
        TRUSTED_PROXIES = "192.168.80.100";

        # Email
        MAIL_MAILER = "stmp";
        MAIL_HOST = "mail.wilkuu.xyz";
        MAIL_FROM_FILE = config.sops.secrets."firefly_iii/email_username".path;
        MAIL_USERNAME_FILE = config.sops.secrets."firefly_iii/email_username".path;
        MAIL_PASSWORD_FILE = config.sops.secrets."firefly_iii/email_password".path;
        MAIL_ENCRYPTION = "starttls";
        MAIL_PORT = 587;
        # Locale and info
        DEFAULT_LOCALE = "nl_NL";
        LANGUAGE = "en_US";
        SITE_OWNER = "jakub@wilkuu.xyz";

      };
    };
    services.firefly-iii-data-importer = mkIf cfg.enable-importer {
      enableNginx = true;
      enable = true;
      virtualHost = cfg.importer-domain;
      user = "firefly_iii";
      group = "nginx";
      settings = {
        FIREFLY_III_URL = "https://${cfg.domain}";
        VANITY_URL = "https://${cfg.domain}";

        # FIREFLY_III_ACCESS_TOKEN = ""; #TODO
        APP_URL = "https://${cfg.importer-domain}";
        LOG_CHANNEL = "syslog";

        # Proxying
        TRUSTED_PROXIES = "192.168.80.100";

        # Email
        MAIL_MAILER = "stmp";
        MAIL_HOST = "mail.wilkuu.xyz";
        MAIL_FROM_FILE = config.sops.secrets."firefly_iii/email_username".path;
        MAIL_USERNAME_FILE = config.sops.secrets."firefly_iii/email_username".path;
        MAIL_PASSWORD_FILE = config.sops.secrets."firefly_iii/email_password".path;
        MAIL_ENCRYPTION = "starttls";
        MAIL_PORT = 587;

        # Locale and info
        FALLBACK_LOCALE = "nl_NL";
        LANGUAGE = "en_US";

      };
    };
  };

}
