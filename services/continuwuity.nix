{
  pkgs,
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
      default = "matrix.${hostname}.local";
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

  };
  config = lib.mkIf cfg.enable {
    services.matrix-continuwuity = {
      enable = cfg.enable;
      package = pkgs.matrix-continuwuity;
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

        # well-known setup
        well_known = {
          client = "https://${cfg.host-domain}";
          server = "${cfg.host-domain}:443";
          support_email = "jakub@wilkuu.xyz";
        };
      };
    };

    services.nginx.virtualHosts =
      let
        socket = "http://unix://${config.services.matrix-continuwuity.settings.global.unix_socket_path}";
      in
      {
        # well-known discovery
        # TODO: Might need to enforce https here, if it already is not.
        ${cfg.fdqn}.locations."/.well_known/matrix/".proxyPass = socket;

        # The matrix server
        ${cfg.host-domain} = {
          enableACME = cfg.doACME;
          forceSSL = cfg.doACME;

          locations."/_matrix".proxyPass = socket;
        };

      };
    # Let nginx access the socket.
    systemd.services.nginx.serviceConfig.SupplementaryGroups = [
      config.services.matrix-continuwuity.group
    ];

  };
}
