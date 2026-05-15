{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.wilkuu.services.bulwark;
  stalwart_cfg = config.wilkuu.services.stalwart;
  hostname = config.networking.hostName;

  # Importing stuff from stalwart and defaults etc.
  _stalwart_jmap_domains = lib.optional stalwart_cfg.enable (
    [ stalwart_cfg.domain ] ++ stalwart_cfg.additionalDomains
  );

  # Secrets handling
  sopsPath = ../secrets/${hostname}/bulwark.yaml;
  secrets = [
    "admin_password"
    "session_secret"
    "oauth_secret"
  ];
  toSops = (sname: "bulwark/${sname}");
  toCredfilePath = (name: config.sops.secrets.${toSops name}.path);
  toSopsPlaceholder = (name: config.sops.placeholder.${toSops name});

  bulwark = pkgs.callPackage ../packages/bulwark/package.nix { };
in
{
  options.wilkuu.services.bulwark = with lib; {
    enable = mkEnableOption "Enable bulwark client";
    doACME = mkEnableOption "Enable ACME for bulwark here";
    package = mkOption {
      type = types.package;
      default = bulwark;
      description = "The bulwark package to be used.";
    };
    domains = mkOption {
      type = (types.listOf types.str);
      default = [ ];
      example = [ "bulwark.wilkuu.xyz" ];
      description = "Domains for HTTP connections";
    };
    dataDir = mkOption {
      type = types.path;
      description = "Storage localtion for Bulwark user data";
      default = "/var/lib/bulwark";
      example = "/srv/data/bulwark";
    };
    jmap_servers = mkOption {
      type = types.listOf types.str;
      default = _stalwart_jmap_domains; # FIXME: What if someone does not want to use all of their stalwart domains here.
      example = [ "jmap.example.com" ];
      description = "A list of JMAP domains avalable for bulwark";
    };
    extraEnv = mkOption {
      type = types.attrs; # TODO Better typing
      default = { };
      example = {
        FAVICON_URL = "static.example.com/favicon.ico";
      };
      description = "Additional configuration, see https://bulwarkmail.org/docs/getting-started/configuration/environment-reference#server-listen-address for more info.";
    };
    stalwartInterop = mkOption {
      type = types.bool;
      default = stalwart_cfg.enable;
      example = true;
      description = "Whenever to allow stalwart-specific features.";
    };

  };

  config.users = lib.mkIf cfg.enable {
    users.bulwark = {
      isSystemUser = true;
      group = "uptimekuma";
    };
    groups.bulwark = { };
  };

  config.wilkuu.services.stalwart.corsDomains = lib.optionals (
    cfg.enable && stalwart_cfg.enable
  ) cfg.domains;
  config.sops.secrets = (
    lib.genAttrs (map toSops secrets) (_name: {
      sopsFile = sopsPath;
      mode = "0440";
      owner = "bulwark";
    })
  );
  config.sops.templates."bulwark-env" = lib.mkIf cfg.enable {
    owner = "bulwark";
    content =
      pkgs.lib.generators.toKeyValue
        {
          mkKeyValue = key: value: "${key}=${lib.escapeShellArg (toString value)}";
        }
        {
          STALWART_FEATURES = "${cfg.stalwartInterop}";
          JMAP_SERVER_URL = lib.concatStringSep cfg.jmap_domains;
          ADMIN_CONFIG_DIR = "${cfg.dataDir}/settings";
          ADMIN_STATE_DIR = "${cfg.dataDir}/admin-state";

          SETTINGS_SYNC_ENABLED = true;
          SETTINGS_DATA_DIR = "${cfg.dataDir}/settings";

          BULWARK_TELEMETRY = "off";
          TELEMETRY_DATA_DIR = "${cfg.dataDir}/telemetry";
          VERSION_CHECK_DATA_DIR = "${cfg.dataDir}/version-check";

          SESSION_SECRET_FILE = toCredfilePath "session_secret";
          ADMIN_PASSWORD = toSopsPlaceholder "admin_password";
          EXTENSION_DIRECTORY_URL = "https://extensions.bulwarkmail.org";

          # Put into a option module
          OAUTH_ENABLED = true;
          OAUTH_CLIENT_ID = "${hostname}-bulwark-webmail";
          OAUTH_ONLY = false;
          # OAUTH_CLIENT_SECRET_FILE = ...
          # TODO: OAUTH_[EXTRA_]SCOPES

          PORT = 3081;
        }
      // cfg.extraEnv;
  };
  config.services.nginx.virtualHosts = lib.mkIf cfg.enable (
    lib.genAttrs cfg.domains (_vhost: {
      addSSL = cfg.doACME;
      enableACME = cfg.doACME;
      locations."/" = {
        proxyPass = "http://localhost:3081";
        recommendedProxySettings = true;
      };
    })
  );

  config.systemd.services.bulwark = lib.mkIf cfg.enable ({
    enable = cfg.enable;
    serviceConfig = {
      User = "bulwark";
      AllowedPorts = 3081;
      SocketBindAllow = "tcp:8080";
      ExecStart = "${cfg.package}";
      WorkingDirectory = "${cfg.dataDir}";
      StateDirectory = "bulwark";
      Restart = "always";
      RestartSec = 5;
      EnvironmentFile = config.sops.templates."bulwark-env".path;
    };
  });
}
