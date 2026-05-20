{ lib, config, ... }:
let
  cfg = config.wilkuu.services.test_endpoint;
in
{
  options.wilkuu.services.test_endpoint = with lib; {
    enable = mkOption {
      type = types.bool;
      default = config.services.nginx.enable;
      description = "Whenever to ssl-terminate a small test-endpoint";
      example = true;
    };
    port = mkOption {
      type = types.port;
      default = 6767;
      description = "The port to forward traffic to";
      example = 6969;
    };
    domain = mkOption {
      type = types.str;
      default = "test.${config.networking.hostName}.wilkuu.xyz";
      description = "The domain to show";
      example = "test.example.com";
    };
    doACME = mkOption {
      type = types.bool;
      default = !config.addons.virtualisation.isTestVM;
      description = "Whenever to enable SSL or not.";
      example = false;
    };
  };
  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts.${cfg.domain} = {
      addSSL = cfg.doACME;
      enableACME = cfg.doACME;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };

  };
}
