{
  lib,
  config,
  inventory,
  self_name,
  options,
  ...
}:
let
  cfg = config.wilkuu.services.prometheus;
  mon = inventory.${self_name}.monitoring;
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    ;
in
{
  options.wilkuu.services.prometheus = {
    enableScraper = mkEnableOption "Prometheus scraper";
    enableExporters = mkEnableOption "Prometheus exporters";
  };

  config = mkMerge [
    (mkIf cfg.enableExporters (
      let
        data = lib.mapAttrs (
          _name: mn:
          let
            default = (builtins.filter (a: builtins.isString a) mn);
            custom = (builtins.filter (a: builtins.isAttrs a) mn);
          in
          {
            ports =
              builtins.map (n: options.services.prometheus.exporters.value.${n}.port) default
              ++ (builtins.map (a: a.port) custom);
            custom_port_mappings = builtins.listToAttrs (
              map ({ name, port, ... }: {
                inherit name;
                value = port;
              }) custom
            );
            exporter_services =
              default
              ++ (builtins.map (a: a.name) (builtins.filter ((a: !(a.skipExporterConfig or false))) custom));
          }
        ) mon;
        data_all = (lib.foldl lib.recursiveUpdate { } (lib.attrValues data));
      in
      {
        # Enable all the exporters outlined in the inventory
        services.prometheus.exporters = lib.genAttrs data_all.exporter_services (name: {
          enable = true;
          port = lib.mkIf (data_all.custom_port_mappings ? name) data_all.custom_port_mappings.${name};

        });
        # Let all the exporters export on all layers
        wilkuu.firewall.layers = lib.mapAttrs (_n: a: {
          allowedTCPPorts = a.ports;
        }) data;
      }
    ))

    (mkIf cfg.enableScraper {
      sops.secrets = {
        "prometheus/stalwart-pass" = {
          sopsFile = ../secrets/${config.networking.hostName}/prometheus.yaml;
          owner = config.systemd.services.prometheus.serviceConfig.User;
        };
        "grafana/secret" = {
          sopsFile = ../secrets/${config.networking.hostName}/prometheus.yaml;
          owner = config.systemd.services.grafana.serviceConfig.User;
        };
      };

      services.grafana = {
        enable = true;
        settings = {
          server = {
            domain = "moni.wilkuu.xyz";
            http_port = 3132;
            http_addr = "0.0.0.0";
            enable_gzip = true;
          };
          security.secret_key = "$__file(${config.sops.secrets."grafana/secret".path})";
        };
      };

      services.prometheus =
        let
          nets_in_layer = inv: layer: lib.filterAttrs (_n: ifi: (ifi.layer or "") == layer) inv.interfaces;
          dests_in_layer =
            inv: layer: port:
            (map (net: "${net.ip}:${toString port}") (lib.attrValues (nets_in_layer inv layer)));

          job_destinations = (
            builtins.foldl'
              (
                acc: perHost:
                (builtins.foldl' (
                  acc2: hostMonitorName:
                  let
                    current = acc2.${hostMonitorName} or [ ];
                    new = perHost.${hostMonitorName};
                  in
                  acc2 // { ${hostMonitorName} = current ++ new; }
                ) acc (lib.attrNames perHost))
              )
              { }
              (
                lib.mapAttrsToList (
                  _host: inv:
                  (lib.foldl' (a: b: a // b) { } (
                    lib.mapAttrsToList (

                      layer: lst:
                      (lib.listToAttrs (
                        builtins.map (
                          a:
                          let
                            ifSimple =
                              a: t: f:
                              if builtins.isString a then t else f;
                            name = ifSimple a a a.name;
                            port = ifSimple a options.services.prometheus.exporters.value.${a}.port (
                              a.port or options.services.prometheus.exporters.${a.name}.port.default
                            );
                          in
                          {
                            inherit name;
                            value = (dests_in_layer inv layer port);
                          }
                        ) lst
                      ))
                    ) inv.monitoring
                  ))
                ) inventory
              )
          );

        in
        {
          enable = true;
          globalConfig = {
            scrape_interval = "10s";
          };
          scrapeConfigs =
            (lib.mapAttrsToList (name: dests: {
              job_name = name;
              static_configs = [
                {
                  targets = dests;
                }
              ];
            }) job_destinations)
            ++ [
              {
                job_name = "stalwart";
                metrics_path = "/metrics/prometheus";
                scheme = "https";
                basic_auth = {
                  username = "prometheus_wilkuu";
                  password_file = config.sops.secrets."prometheus/stalwart-pass".path;
                };
                static_configs = [
                  {
                    targets = [ "mail.wilkuu.xyz:443" ];
                  }
                ];
              }
            ];
        };
    })
  ];
}
