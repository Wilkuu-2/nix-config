{ lib, config, ... }:
let
  cfg = config.wilkuu.services.prometheus;
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkDefault
    ;
in
{
  options.wilkuu.services.prometheus = {
    enableScraper = mkEnableOption "Prometheus scraper";
    enableExporters = mkEnableOption "Prometheus exporters";
  };

  config = mkMerge [
    (mkIf cfg.enableExporters {
      services.prometheus.exporters = {
        wireguard.enable = mkDefault config.networking.wireguard.enable;
        fail2ban.enable = mkDefault config.services.fail2ban.enable;
        node = {
          enable = true;
        };
      };

    })
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
          omega-relay-ip = "192.168.80.100";
        in
        {
          enable = true;
          globalConfig = {
            scrape_interval = "10s";
          };
          scrapeConfigs = [
            {
              job_name = "node";
              static_configs =
                let
                  port = toString config.services.prometheus.exporters.node.port;
                in
                [
                  {
                    targets = [
                      "localhost:${port}"
                      "${omega-relay-ip}:${port}"
                    ];
                  }
                ];
            }
            {
              job_name = "wireguard";
              static_configs =
                let
                  port = toString config.services.prometheus.exporters.wireguard.port;
                in
                [
                  { targets = [ "${omega-relay-ip}:${port}" ]; }
                ];
            }
            {
              job_name = "fail2ban";
              static_configs =
                let
                  port = toString config.services.prometheus.exporters.fail2ban.port;
                in
                [
                  { targets = [ "${omega-relay-ip}:${port}" ]; }
                ];

            }
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
            {
              job_name = "mikrotik";
              static_configs =
                let
                  port = toString config.services.prometheus.exporters.fail2ban.port;
                in
                [
                  { targets = [ "localhost:${port}" ]; }
                ];

            }
          ];
        };
    })
  ];
}
