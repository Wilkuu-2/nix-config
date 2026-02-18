{ config, lib, ... }:
let
  cfg = config.wilkuu.services.stalwart;
  hostname = config.networking.hostName;
in
{
  options.wilkuu.services.stalwart = with lib; {
    domain = mkOption {
      type = types.str;
      default = "mail.${hostname}.local";
      example = "mail.wilkuu.xyz";
      description = "Domain for http connections.";
    };
    additionalDomains = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "mail.wilkuu.xyz" ];
      description = "Domain for http connections.";
    };
    wellKnownDomains = mkOption {
      type = types.listOf types.str;
      default = [ "${hostname}.local" ];
      example = [ "wilkuu.xyz" ];
      description = "Domain for well-known items";
    };
    doACME = mkEnableOption "Enable ACME for stalwart here";
    enable = mkEnableOption "Enable the email service";
    dataDir = mkOption {
      type = types.path;
      description = "Storage localtion for Stalwart user data";
      default = "/srv/data/stalwart";
      example = "/srv/data/stalwart";
    };
  };

  config = lib.mkIf cfg.enable (
    let
      sopsPath = ../secrets/${hostname}/stalwart.yaml;
      secrets = [ "user_admin_password" ];
      toSops = (sname: "stalwart/${sname}");
      toCredfilePath = (name: config.sops.secrets.${toSops name}.path);
      toStalwartCred = name: "%{file:/run/credentials/${config.systemd.services.stalwart.name}/${name}}%";

      basicListener = proto: port: tls: {
        bind = [ "[::]:${toString port}" ];
        protocol = proto;
        tls.implicit = tls;
      };

      proxyWellKnown =
        names:
        let
          uris = map (n: "/.well-known/${n}") names;
        in
        (lib.genAttrs uris (uri: {
          proxyPass = "http://localhost:3080${uri}";
          recommendedProxySettings = true;
        }));

      makeHttpRedirect = target: https: {
        return = "302 ${if https then "https" else "http"}://${target}";
      };

    in
    {
      networking.hosts = {
        "127.0.0.1" = ([ cfg.domain ] ++ cfg.additionalDomains);
      };

      # Need this bc otherwise sops will complain for some reason
      users = {
        groups.stalwart = { };
        users.stalwart = {
          isSystemUser = true;
          group = "stalwart";
        };
      };

      # TODO: Move this into a util function or option;
      sops.secrets = (
        lib.genAttrs (map toSops secrets) (_name: {
          sopsFile = sopsPath;
          mode = "0440";
          owner = "stalwart-mail";
        })
      );

      services.nginx.virtualHosts =
        (lib.genAttrs cfg.wellKnownDomains (_wdomain: {
          locations =
            (proxyWellKnown [
              "jmap"
              "mta-sts.txt"
              "mail-v1.xml"
              "autoconfig/mail"
            ])
            // (lib.genAttrs [ "/.well-known/caldav/" "/.well-known/webdav/" ] (
              uri: (makeHttpRedirect "${cfg.domain}${uri}") cfg.doACME
            ));
        }))
        // (lib.genAttrs ([ cfg.domain ] ++ cfg.additionalDomains) (domain: {
          addSSL = cfg.doACME;
          enableACME = cfg.doACME;
          serverName = "${domain}";
          locations."/" = {
            proxyPass = "http://localhost:3080";
            recommendedProxySettings = true;
          };
        }));

      services.stalwart = {
        enable = true;
        dataDir = cfg.dataDir;
        openFirewall = false;
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
            ) ([ cfg.domain ] ++ cfg.additionalDomains)
          ));

        settings = {
          server.listener = {
            smtp = basicListener "smtp" 25 false;
            submission = basicListener "smtp" 465 true;
            imaptls = basicListener "imap" 993 true;
            imap = basicListener "imap" 143 true;
            # webdav = basicListener "http" 3080 false;
            # jmap = basicListener "http" 3080 false;
            http = basicListener "http" 3080 false;
          };

          store.rocksdb = {
            type = "rocksdb";
            path = cfg.dataDir;
            compression = "lz4";
          };

          directory.internal = {
            type = "internal";
            store = "rocksdb";
          };

          storage = {
            data = "rocksdb";
            fts = "rocksdb";
            blob = "rocksdb";
            lookup = "rocksdb";
            directory = "internal";
          };

          authentication.fallback-admin = {
            user = "admin";
            secret = toStalwartCred "user_admin_password";
          };

          http = {
            use-x-forwarded = true;
            url = "protocol + \"://${cfg.domain}\"";
          };

          session.connect = {
            hostname = "config_get('server.hostname')";
          };

          server.hostname = "${cfg.domain}";

          certificate = (
            lib.mkIf (cfg.doACME) (
              lib.genAttrs (map (d: "nix_${d}") ([ cfg.domain ] ++ cfg.additionalDomains)) (
                _name:
                let
                  domain = lib.string.removePrefix "nix_" domain;
                in
                {
                  cert = toStalwartCred "tls_${domain}_cert.pem";
                  private-key = toStalwartCred "tls_${domain}_key.pem";
                  default = (domain == cfg.domain);
                }
              )
            )
          );
        };
      };
    }
  );
}
