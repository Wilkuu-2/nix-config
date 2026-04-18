{
  pkgs,
  config,
  lib,
  ...
}:
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
    stateVersion = mkOption {
      type = types.str;
      description = "The nixos version which is the version you started stalwart for the first time.";
      example = "25.11";
      default = "25.11";
    };
    corsDomains = mkOption {
      type = types.listOf types.str;
      description = "List of domains that are permitted by cors";
      example = [ ];
      default = [ ];
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

      makeHTTPRedirectBody = target: https: "302 ${if https then "https" else "http"}://${target}";

      # TODO: Move to a util
      # TODO: Make it so the user can define the method for each origin.
      nginxDomainRegex = domain: "~^https://${lib.replaceString "." "\\." domain}";
      nginxCorsMap = name: domains: ''
        	# Create a map for CORS for ${name}
          map $http_origin $cors_${name} {
            default "";
          ${lib.concatLines (builtins.map (d: "    ${nginxDomainRegex d} $http_origin;") domains)}
          }
      '';
      read_only_methods = "GET, OPTIONS";
      rest_methods = read_only_methods + "," + "POST, PUT, DELETE";
      webdav_methods = "PROPFIND, PROPPATCH, COPY, LOCK, UNLOCK, MKCOL, MOVE";
      all_methods = rest_methods + ", " + webdav_methods;

      # Source https://enable-cors.org/server_nginx.html feat. ClankGPT
      nginxCorsInclude =
        name: allowed_methods:
        pkgs.writeText "nginx-cors-${name}-headers" ''
                	# Adds cors headers
                  if ($request_method = OPTIONS) {
          		add_header 'Vary' 'Origin' always;
          		add_header 'Access-Control-Allow-Origin' $cors_${name};
          		add_header 'Access-Control-Allow-Methods' '${allowed_methods}';
          		add_header 'Access-Control-Allow-Credentials' 'true';
          		add_header 'Access-Control-Allow-Headers' 'DNT, User-Agent, X-Requested-With, If-Modified-Since,Cache-Control,Content-Type,Range,Authorization';

          	  	add_header 'Access-Control-Max-Age' 86400;
          	  	add_header 'Content-Type' 'text/plain; charset=utf-8';
          	  	add_header 'Content-Length' 0;
                    	return 204;
                  }
                  add_header 'Vary' 'Origin' always;
          	add_header 'Access-Control-Allow-Origin' $cors_${name};
          	add_header 'Access-Control-Allow-Methods' '${allowed_methods}';
          	add_header 'Access-Control-Allow-Credentials' 'true';
          	add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization';
        '';

      stalwart_cors_headers = nginxCorsInclude "stalwart" all_methods;
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
              "mta-sts.txt"
              "mail-v1.xml"
              "autoconfig/mail"
            ])
            // (lib.genAttrs [ "/.well-known/caldav/" "/.well-known/webdav/" "/.well-known/jmap" ] (uri: {
              extraConfig = ''
                	  	   include ${stalwart_cors_headers};
                	      	   return ${makeHTTPRedirectBody "${cfg.domain}${uri}" cfg.doACME};
                		'';
            }));
        }))
        // (lib.genAttrs ([ cfg.domain ] ++ cfg.additionalDomains) (domain: {
          addSSL = cfg.doACME;
          enableACME = cfg.doACME;
          serverName = "${domain}";
          locations."/" = {
            proxyPass = "http://localhost:3080";
            proxyWebsockets = true;
            recommendedProxySettings = true;
            extraConfig = "include ${stalwart_cors_headers};";
          };
        }));
      services.nginx.commonHttpConfig = nginxCorsMap "stalwart" cfg.corsDomains;

      services.stalwart = {
        inherit (cfg) stateVersion dataDir enable; # Note set this to something else if you were to copy this module.
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
                  domain = lib.strings.removePrefix "nix_" _name;
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
