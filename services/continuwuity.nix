{
  config,
  lib,
  ...
}:
let
  cfg = config.wilkuu.services.continuwuity;
  hostname = config.netowrking.hostName;
  inherit (lib) mkOption types mkEnableOption;
in
{
  options.wilkuu.services.continuwuity = {
    host-domain = mkOption {
      type = types.str;
      default = "matrix.${cfg.fdqn}";
      example = "matrix.wilkuu.xyz";
      description = "The hosting address of the server";
    };

    livekit-domain = mkOption {
      type = types.str;
      default = "lk.${cfg.fdqn}";
      example = "matrix.wilkuu.xyz";
      description = "The hosting address of the server";
    };

    fdqn = mkOption {
      type = types.str;
      default = "${hostname}.local";
      example = "wilkuu.xyz";
      description = "The domain displayed in the addresses for users/rooms";
    };

    doACME = mkEnableOption "Enable ACME for stalwart here";
    enable = mkEnableOption "Enable the matrix server";
    dataDir = mkOption {
      type = types.path;
      description = "Storage localtion for Stalwart user data";
      default = "/srv/data/continuwuity";
      example = "/srv/data/continuwuity";
    };
    allowRegistration = mkEnableOption "allow random people to register";
    allowFederation = mkEnableOption "allow other servers to federate";
    trustedServers = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "matrix.org" ];
      description = "The trusted matrix servers.";
    };

    networkLayer = mkOption {
      type = types.str;
      default = "external";
      example = "internal";
      description = "layer for the firewall";
    };

  };
  config = lib.mkIf cfg.enable (
    let
      keyFile = config.sops.secrets."continuwuity/livekit-keys".path;
      keyGroup = "lk-keys";
    in
    {
      users.groups.${keyGroup} = { };
      sops.secrets."continuwuity/livekit-keys" = {
        sopsFile = ../secrets/${config.networking.hostName}/livekit_keys.bin;
        group = keyGroup;
        key = "";
        format = "binary";
      };

      wilkuu.firewall.layers.${cfg.networkLayer} = {
        allowedTCPPorts = [ 7881 ];
        allowedUDPPortRanges = [
          {
            from = 42000;
            to = 42069;
          }
        ];
      };
      services.livekit = {
        enable = true;
        inherit keyFile;
        settings = {
          port = 10004;
          # bind_addresses = [ "0.0.0.0" ];
          rtc = {
            tcp_port = 7881;
            port_range_start = 42000;
            port_range_end = 42069;
          };
        };
      };

      # Ensure access to secrets
      systemd.services.livekit.serviceConfig.SupplementaryGroups = [ keyGroup ];
      systemd.services.lk-jwt-service.serviceConfig.SupplementaryGroups = [ keyGroup ];

      services.lk-jwt-service = {
        enable = true;
        port = 10003;
        livekitUrl = "wss://${cfg.livekit-domain}";
        inherit keyFile;
      };
      systemd.services.lk-jwt-service.environment = {
        LIVEKIT_JWT_BIND = lib.mkForce "127.0.0.1:10003";
        LIVEKIT_FULL_ACCESS_HOMESERVERS = "wilkuu.xyz";
      };

      services.matrix-continuwuity = {
        enable = cfg.enable;
        # package = inputs.continuwuity.packages.${pkgs.stdenv.hostPlatform.system}.default;
        settings.global = {
          # Hosted at cfg.domain, server fdqn is fdqn.
          server_name = cfg.fdqn;
          # Remove the trans flag, it is a nice feature but not my style.
          new_user_displayname_suffix = "";

          # Configure matrix stuffs
          allow_registration = cfg.allowRegistration;
          allow_encryption = true;
          allow_federation = cfg.allowFederation;
          trusted_servers = cfg.trustedServers;

          ip_lookup_strategy = 4;

          # Host the server on a unix-socket and use nginx to connect to that socket.
          address = null;
          unix_socket_path = "/run/continuwuity/continuwuity.sock";
          unix_socket_perms = 660;

          # You can run this once to create a user called harbinger which is admin.
          # This might not be needed to bootstrap c10y in the later versions.
          # It will crash c10y if the user already exists (Idk what the workaround is)
          # admin_execute = [
          #   "users create-user harbinger"
          #   "users make-user-admin harbinger"
          # ];

          url_preview_domain_explicit_allowlist = [
            "i.imgur.com"
            "cdn.discordapp.com"
            "ooye.elisaado.com"
            "media.tenor.com"
            "media1.tenor.com"
            "tenor.com"
            "giphy.com"
            "cdn.nest.rip"
            "ssd-cdn.nest.rip"
            "i.github.com"
            "github.com"
            "wilkuu.xyz"
          ];

          # well-known setup
          well_known = {
            client = "https://${cfg.host-domain}";
            server = "${cfg.host-domain}:443";
            support_email = "jakub@wilkuu.xyz";
          };

          # allow livekit/matrix_rtc
          matrix_rtc.foci = [
            {
              type = "livekit";
              livekit_service_url = "https://${cfg.livekit-domain}";
            }
          ];
        };
      };

      services.nginx.virtualHosts =
        let
          socket = "http://unix://${config.services.matrix-continuwuity.settings.global.unix_socket_path}";
        in
        {
          # well-known discovery
          # TODO: Might need to enforce https here, if it already is not.
          ${cfg.fdqn}.locations."/.well-known/matrix/".proxyPass = socket;

          ${cfg.livekit-domain} = {
            forceSSL = cfg.doACME;
            useACMEHost = lib.mkIf cfg.doACME cfg.fdqn;
            locations = {
              "~ ^/(sfu/get|healthz|get_token)" = {
                proxyPass = "http://${config.systemd.services.lk-jwt-service.environment.LIVEKIT_JWT_BIND}/$1";
                recommendedProxySettings = true;
              };
              "/" = {
                proxyPass = "http://localhost:${toString config.services.livekit.settings.port}/";
                recommendedProxySettings = true;
                proxyWebsockets = true;
              };
            };
          };

          # The matrix server
          ${cfg.host-domain} = {
            enableACME = cfg.doACME;
            forceSSL = cfg.doACME;

            locations = {
              "/_matrix".proxyPass = socket;
            };
          };
        };
      # Let nginx access the socket.
      systemd.services.nginx.serviceConfig.SupplementaryGroups = [
        config.services.matrix-continuwuity.group
      ];

    }
  );
}
