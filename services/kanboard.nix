{pkgs, config, lib, ...}:
  let 
    cfg = config.wilkuu.services.kanboard; 
    inherit (lib) mkEnableOption mkOption types mkIf; 
  in 
{
  options.wilkuu.services.kanboard = {
    enable = mkEnableOption "kanboard"; 
    domain = mkOption {
      type = types.str; 
      example = "kb.wilkuu.xyz";
    };
  }; 

  config = mkIf cfg.enable {
    wilkuu.services.mysql.unix_users = ["kanboard"];
    wilkuu.mjmap = { 
      enable = lib.mkDefault true; 
      users = ["kanboard"];
    };  
    sops.secrets."kanboard/db_password" = {
      sopsFile = ../secrets/${config.networking.hostName}/kanboard.yaml; 
      owner = "kanboard"; 
      mode = "500"; 
    };  
    sops.templates."kanboard-env" = {
      content = ''
        DB_PASSWORD=${config.sops.placeholder."kanboard/db_password"}
        PLUGIN_INSTALLER=true
      ''; 
      owner = "kanboard"; 
      mode  = "500"; 
    };
    systemd.services.phpfpm-kanboard.serviceConfig = {
      EnvironmentFile = config.sops.templates."kanboard-env".path; 
    };  
    services.kanboard = {
      nginx = {
        enableACME = false;
        forceSSL = false;
        addSSL = false; 
      };
      domain = cfg.domain; 
      enable = true; 
      settings = {
        PLUGIN_INSTALLER = "$PLUGIN_INSTALLER";
        PLUGINS_DIR = "${config.services.kanboard.dataDir}/plugins";
        MAIL_FROM = "Kanboard <noreply@wilkuu.nl>"; 
        MAIL_TRANSPORT = "sendmail";
        MAIL_SENDMAIL_COMMAND = "sendmail";
        DB_DRIVER = "mysql"; 
        DB_USERNAME = "kanboard"; 
        DB_HOSTNAME = "127.0.0.1;unix_socket=/run/mysqld/mysqld.sock";
        DB_PASSWORD = "$DB_PASSWORD"; 
        ENABLE_URL_REWRITE = true;
        TRUSTED_PROXY_HEADERS = "HOST,X-REAL-IP,X-FORWARDED-FOR,X-FORWARDED-HOST,X-FORWARDED-SERVER";
        TRUSTED_PROXY_NETWORKS = "192.168.80.0/24,192.168.88.0/24";
      };
    };
  };
}
