{
  config,
  lib,
  ...
}:
let
  cfg = config.wilkuu.services.mail;
  hostname = config.networking.hostName;
in
{
  options.wilkuu.services.mail = with lib; {
    enable = mkEnableOption "Enable webmail";
    doACME = mkEnableOption "Enable ACME for stalwart here";
    defaultDomain = mkOption {
      type = lib.types.str;
      default = "mail.${hostname}.local";
      example = "mail.wilkuu.xyz";
      description = "Domain for http connections.";
    };
    domains = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "mail.wilkuu.xyz" ];
      description = "Domains for email.";
    };
    wellKnownDomains = mkOption {
      type = types.listOf types.str;
      default = [ "${hostname}.local" ];
      example = [ "wilkuu.xyz" ];
      description = "Domain for well-known items";
    };
    extraConfig = mkOption {
      type = types.listOf types.attrs;
      description = "Additional plan steps added to the stalwart config";
      default = [ ];
      example = [ ];
    };
    extraCreate = mkOption {
      type = types.listOf types.attrs;
      description = "Additional idempotent create steps added to the stalwart config";
      default = [ ];
      example = [ ];
    };

    startupMode = mkOption {
      type = types.enum [
        "normal"
        "bootstrap"
        "recovery"
      ];
      description = "Whenever to use the bootstrap or recovery mode, see https://stalw.art/docs/configuration/bootstrap-mode/ and https://stalw.art/docs/configuration/recovery-mode/";
      default = "normal";
      example = "bootstrap";
    };

  };

  config = lib.mkIf cfg.enable (
    let
      sopsPath = ../secrets/${hostname}/stalwart.yaml;
      secrets = [
        "admin_user"
        "admin_password"
        "recovery_user"
        "recovery_password"
        "oidc_secret"
      ];
      toSops = (sname: "stalwart16/${sname}");
      toPlaceholder = (sname: config.sops.placeholder.${toSops sname});
      toCredfilePath = (name: config.sops.secrets.${toSops name}.path);

      # We do this to satisfy the foreign key constraint of the SystemSettings singleton
      proxyWellKnown =
        names:
        let
          uris = map (n: "/.well-known/${n}") names;
        in
        (lib.genAttrs uris (uri: {
          proxyPass = "http://127.0.0.1:8080${uri}";
          recommendedProxySettings = true;
        }));
      makeHTTPRedirectBody = target: https: "302 ${if https then "https" else "http"}://${target}";

    in
    {
      users.users.stalwart = {
        isSystemUser = true;
        group = "stalwart";
      };
      users.groups.stalwart = { };
      sops.secrets = (
        lib.genAttrs (map toSops secrets) (_name: {
          sopsFile = sopsPath;
          mode = "0440";
          owner = "stalwart";
        })
      );

      sops.templates = {
        stalwart-config-creds = {
          owner = "stalwart";
          mode = "0440";
          content = ''
            STALWART_USER=${toPlaceholder "admin_user"}
            STALWART_PASSWORD=${toPlaceholder "admin_password"}
          '';
        };
        stalwart-recovery-creds = {
          owner = "stalwart";
          mode = "0440";
          content = ''
            STALWART_RECOVERY_ADMIN=${toPlaceholder "recovery_user"}:${toPlaceholder "recovery_password"}
          '';
        };
      };
      
      security.acme.certs.${cfg.defaultDomain}.extraLegoRenewFlags = [
        "--reuse-key"
      ];
      services.nginx.enable = lib.mkDefault true;
      services.nginx.virtualHosts =
        (lib.genAttrs
          (lib.concatLists [
            cfg.wellKnownDomains
            cfg.domains
            [ cfg.defaultDomain ]
          ])
          (_wdomain: {
            forceSSL = lib.mkDefault cfg.doACME;
            enableACME = lib.mkDefault cfg.doACME;
            locations =
              (proxyWellKnown [
                "mta-sts.txt"
                "mail-v1.xml"
                "autoconfig/mail"
                "openid-configuration"
                "oauth-authorization-server"
              ])
              // (lib.genAttrs [ "/.well-known/caldav/" "/.well-known/webdav/" "/.well-known/jmap" ] (uri: {
                extraConfig = ''
                  	return ${makeHTTPRedirectBody "${cfg.defaultDomain}${uri}" cfg.doACME};
                '';
              }));

          })
        )
        // (lib.genAttrs [ cfg.defaultDomain ] (_domain: {
          forceSSL = cfg.doACME;
          enableACME = cfg.doACME;
          #serverName = "${domain}";
          locations."/" = {
            proxyPass = "http://127.0.0.1:8080";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };
        }));

      stalwart-nix.stalwart = let 
      in {
        enable = cfg.enable;
        url = if cfg.startupMode != "normal" then "http://127.0.0.1:8080/" else "http://${cfg.defaultDomain}";
        credentialsFile = config.sops.templates.stalwart-config-creds.path;
        recoveryCredentialsFile = config.sops.templates.stalwart-recovery-creds.path;
        startupMode = cfg.startupMode;
        user = "stalwart";
        group = "stalwart";
        configPlanPre = [];
        idempotentCreate = cfg.extraCreate;
        configPlanPost =   cfg.extraConfig;
        credentials =
          (lib.genAttrs secrets toCredfilePath)
          // (builtins.foldl' (a: b: a // b) ({ }) (
            map (
              domain:
              let
                acme_dir = config.security.acme.certs.${domain}.directory;
                cert_path = file: "${acme_dir}/${file}";
              in
              {
                "tls_${domain}_cert.pem" = cert_path "cert.pem";
                "tls_${domain}_key.pem" = cert_path "key.pem";
              }
            ) (lib.optionals cfg.doACME (lib.unique ([ cfg.defaultDomain ] ++ cfg.domains)))
          ));
      };
    }
  );

}
