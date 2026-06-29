{ lib, config, ... }:
let
  inherit (lib)
    mkOption
    types
    mkEnableOption
    mkIf
    ;

  cfg = config.wilkuu.services.desecDyn;
in
{
  options.wilkuu.services.desecDyn = {
    enable = mkEnableOption "Dynamic DNS management through desec.io";

    domains = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            # TODO: Decide on defaults
            doWildcard = mkEnableOption "requesting a wildcard zone/cert";
            enableDDNS = mkEnableOption "setting A/AAAA records for the domain";
            enableACME = mkEnableOption "requesting certificates for the domain";
          };
        }
      );
      description = "List of all domains to be managed through desec.io";
      example = {
        "example.dedyn.io" = {
          doWildcard = true;
          enableDDNS = true;
          enableACME = true;
        };
      };
      default = { };
    };
    tokenSopsName = mkOption {
      type = types.str;
      description = "Sops-nix secret name";
    };
  };
  config =
    let
      ddns-updater-configs = builtins.concatLists (
        builtins.attrValues (
          lib.mapAttrs (
            name: dcfg:
            (
              lib.optional dcfg.doWildcard ({
                provider = "desec";
                domain = "*.${name}";
                token = config.sops.placeholder.${cfg.tokenSopsName};
                ip_version = "ipv4";
              })
              ++ [
                {
                  provider = "desec";
                  domain = name;
                  token = config.sops.placeholder.${cfg.tokenSopsName};
                  ip_version = "ipv4";
                }
              ]
            )
          ) (lib.filterAttrs (_: dcfg: dcfg.enableDDNS) cfg.domains)
        )
      );
      enableDDNS = ddns-updater-configs != [ ];

      acme-certs = (
        lib.mapAttrs (dname: dcfg: {
          domain = dname;
          # TODO: Make a special group so that you can give access to other stuff.
          group = config.services.nginx.group;
          dnsProvider = "desec";
          environmentFile = config.sops.templates.acme-envfile.path;
          extraDomainNames = (lib.optional dcfg.doWildcard "*.${dname}");
        }) (lib.filterAttrs (_: dcfg: dcfg.enableACME) cfg.domains)
      );

    in
    mkIf cfg.enable {
      users.groups.ddns = mkIf enableDDNS { };
      sops.templates.ddns-updater-config = mkIf (enableDDNS) {
        mode = "0440";
        group = "ddns";
        content = lib.generators.toJSON { } {
          settings = ddns-updater-configs;
        };
      };
      sops.templates.acme-envfile = {
        content = ''
          DESEC_TOKEN=${config.sops.placeholder.${cfg.tokenSopsName}}
        '';
      };
      systemd.services.ddns-updater.serviceConfig = {
        SupplementaryGroups = [ "ddns" ];
      };
      services.ddns-updater = {
        enable = enableDDNS;
        environment = {
          SERVER_ENABLED = "no";
          PERIOD = "60m";
          CONFIG_FILEPATH = config.sops.templates.ddns-updater-config.path;
        };
      };

      security.acme.certs = acme-certs;
    };
}
