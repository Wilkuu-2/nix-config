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
  imports = [ ./stalwart0_16.nix ];
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
      tools = config.wilkuu.services.stalwart16.toolbox;
      sopsPath = ../secrets/${hostname}/stalwart.yaml;
      secrets = [
        "admin_user"
        "admin_password"
        "recovery_user"
        "recovery_password"
      ];
      toSops = (sname: "stalwart16/${sname}");
      toPlaceholder = (sname: config.sops.placeholder.${toSops sname});
      toCredfilePath = (name: config.sops.secrets.${toSops name}.path);

      domain_to_jid = lib.replaceString "." "_";
      # We do this to satisfy the foreign key constraint of the SystemSettings singleton
      placeholderDomain = "bootstrap-placeholder.home.arpa";
      planPreamble = lib.concatLists [
        (tools.mkIdempotentCreateLine {
          "object" = "Domain";
          deleteBy = "name";
          value."#placeholder-domain" = {
            name = placeholderDomain;
            certificateManagement = {
              "@type" = "Manual";
            };
            dnsManagement = {
              "@type" = "Manual";
            };
            dkimManagement = {
              "@type" = "Manual";
            };
            subAddressing = {
              "@type" = "Enabled";
            };
          };
        })
        [
          {
            "@type" = "update";
            "object" = "SystemSettings";
            "value" = {
              "defaultDomainId" = "#placeholder-domain";
            };
          }
        ]
      ];
      # TODO: Is this nice, or is using 1 object better?
      #       This approach makes it more atomic afaik?
      domainCreateRules = (
        lib.forEach cfg.domains (domain: {
          object = "Domain";
          deleteBy = "name";
          value.${domain_to_jid domain} = {
            name = domain;
            certificateManagement = {
              "@type" = "Manual";
            };
            dnsManagement = {
              "@type" = "Manual";
            };
            dkimManagement = {
              "@type" = "Manual";
            };
            subAddressing = {
              "@type" = "Enabled";
            };
          };
        })
      );
      certificateCreateRules = lib.optionals cfg.doACME (
        lib.forEach (lib.unique ([ cfg.default_domain ] ++ cfg.domains)) (
          (domain: {
            object = "Certificate";
            deleteBy = "certificate.filePath";
            value."cert_${domain_to_jid domain}" = {
              certificate = {
                "@type" = "File";
                filePath = "/run/credentials/stalwart.service/tls_${domain}_cert.pem";
              };
              privateKey = {
                "@type" = "File";
                filePath = "/run/credentials/stalwart.service/tls_${domain}_key.pem";
              };
            };
          })

        )
      );
      baseSetupRules = [
        {
          "@type" = "update";
          "object" = "SystemSettings";
          "value" = {
            "defaultDomainId" = "#${domain_to_jid (builtins.elemAt cfg.domains 0)}";
            "defaultHostname" = cfg.defaultDomain;
          };
        }
        {
          "@type" = "update";
          "object" = "BlobStore";
          "value" = {
            "@type" = "Default";
          };
        }
        {
          "@type" = "update";
          "object" = "InMemoryStore";
          "value" = {
            "@type" = "Default";
          };
        }
        {
          "@type" = "update";
          "object" = "SearchStore";
          "value" = {
            "@type" = "Default";
          };
        }
      ];
      proxyWellKnown =
        names:
        let
          uris = map (n: "/.well-known/${n}") names;
        in
        (lib.genAttrs uris (uri: {
          proxyPass = "http://localhost:3080${uri}";
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

      services.nginx.enable = lib.mkDefault true;
      services.nginx.virtualHosts =
        (lib.genAttrs
          (lib.concatLists [
            cfg.wellKnownDomains
            cfg.domains
            [ cfg.defaultDomain ]
          ])
          (_wdomain: {
            addSSL = lib.mkDefault cfg.doACME;
            enableACME = lib.mkDefault cfg.doACME;
            locations =
              (proxyWellKnown [
                "mta-sts.txt"
                "mail-v1.xml"
                "autoconfig/mail"
                "openid-configuration"
                "/.well-known/oauth-authorization-server"
              ])
              // (lib.genAttrs [ "/.well-known/caldav/" "/.well-known/webdav/" "/.well-known/jmap" ] (uri: {
                extraConfig = ''
                  	return ${makeHTTPRedirectBody "${cfg.domain}${uri}" cfg.doACME};
                '';
              }));

          })
        )
        // (lib.genAttrs [ cfg.defaultDomain ] (_domain: {
          addSSL = cfg.doACME;
          enableACME = cfg.doACME;
          #serverName = "${domain}";
          locations."/" = {
            proxyPass = "http://localhost:8080";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };
        }));

      wilkuu.services.stalwart16 = {
        enable = cfg.enable;
        url = if cfg.startupMode != "normal" then "http://localhost:8080/" else cfg.defaultDomain;
        credentialsFile = config.sops.templates.stalwart-config-creds.path;
        recoveryCredentialsFile = config.sops.templates.stalwart-recovery-creds.path;
        startupMode = cfg.startupMode;
        user = "stalwart";
        group = "stalwart";
        configPlanPre = planPreamble;
        idempotentCreate = certificateCreateRules ++ domainCreateRules ++ cfg.extraCreate;
        configPlanPost = baseSetupRules ++ cfg.extraConfig;
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
