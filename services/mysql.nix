{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.wilkuu.services.mysql;

  create_users_ensure =
    uname:
    (lib.genAttrs (lib.map (dn: "${dn}.*") (
      lib.attrNames (lib.filterAttrs (_: dcfg: (builtins.elem uname dcfg.allowedUsers)) cfg.databases)
    )) (_: "ALL PRIVILEGES"));

  priviledge_clause =
    name: db: priv:
    ("GRANT ${priv} ON ${db} TO ${name};");

  add-user-clauses =
    name: ucfg:
    if (!isNull ucfg.sopsPlaceholder) then
      (
        ''
          -- Clauses for user ${name}
          ALTER USER IF EXISTS '${name}'@'%' IDENTIFIED BY '${ucfg.sopsPlaceholder}'; 
          CREATE USER IF NOT EXISTS '${name}'@'%' IDENTIFIED BY '${ucfg.sopsPlaceholder}';  
        ''
        + (lib.concatMapAttrsStringSep "\n" (priviledge_clause "'name'@'%'") (create_users_ensure name))
      )
    else
      " -- Ommitted user ${name}";

  add-unix-user-clauses =
    name:
    ''
      -- Clauses for user ${name}
      ALTER USER IF EXISTS '${name}'@'localhost' IDENTIFIED VIA unix_socket; 
      CREATE USER IF NOT EXISTS '${name}'@'localhost' IDENTIFIED VIA unix_socket;  
    ''
    + (lib.concatMapAttrsStringSep "\n" (priviledge_clause "'${name}'@'localhost'") (
      create_users_ensure name
    ));

in
{
  options.wilkuu.services.mysql = {
    enable = lib.mkEnableOption "Enable database for containers";
    port =
      with lib;
      mkOption {
        type = types.port;
        default = 3306;
      };
    databases =
      with lib;
      mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              enable = mkEnableOption "Enable the database";
              allowedUsers = mkOption {
                type = types.listOf types.str;
              };
            };
          }
        );
        default = { };
      };
    users =
      with lib;
      mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              scramPassword = mkOption {
                type = types.nullOr types.str;
                default = null;
              };
              sopsPlaceholder = mkOption {
                type = types.nullOr types.str;
                default = null;
              };
              allowedRanges = mkOption {
                type = types.listOf types.str;
              };
            };
          }
        );
        default = { };
      };
    unix_users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Users that can identify using the unix socket";
      default = [ ];
      example = [ "wakapi" ];
    };
  };
  # config.sops.secrets = lib.mkIf cfg.enable {
  #   "database/root_pass" = {
  #     sopsFile = ../secrets/${config.networking.hostName}/secrets.yaml;
  #   };
  # };
  config.sops.templates."init-mysql" = lib.mkIf cfg.enable {
    owner = config.systemd.services.mysql.serviceConfig.User;
    content = (
      lib.concatLines (
        (builtins.attrValues (builtins.mapAttrs add-user-clauses cfg.users))
        ++ (map add-unix-user-clauses cfg.unix_users)
        ++ [ "FLUSH PRIVILEGES;" ]
      )
    );
  };

  config.services.mysql = {
    enable = cfg.enable;
    ensureDatabases = builtins.attrNames cfg.databases;
    initialScript = config.sops.templates."init-mysql".path;
    package = pkgs.mariadb;
    settings = {
      mysqld = {
        # socket="/var/lib/mysql/mysql.sock";
        log_error = "/var/log/mysql_err.log";
        log_warnings = 2;
      };
    };
  };

  # config.host-config.utilpkgs = lib.mkIf (cfg.enable) (
  #   with pkgs;
  #   [
  #     mycli
  #   ]
  # );
}
