{
  pkgs,
  config,
  lib,
}:
let
  cfg = config.wilkuu.services.gomuks;
  hostname = config.networking.hostName;
in
{
  options.wilkuu.serivces.gomuks = with lib; {
    enable = mkEnableOption "Enable gomuks";
    # Hostname option is reused a lot, we might need to create a util for the options at this rate.
    hostname = mkOption {
      type = types.str;
      default = "$matrix.{config.networking.hostName}.local";
      description = "Hostname on which gomuks should be hosted.";
    };
    package = mkPackageOption pkgs "gomuks-web" { };
    dataDir = mkOption {
      type = types.path;
      default = "/srv/gomuks/";
      description = "Directory for where gomuks will store it's files.";
    };

  };
  config = lib.mkIf cfg.enable (
    let
      yaml = pkgs.writers.writeYAML;
      cfgDir = "${cfg.dataDir}/.config";
      configFile = yaml.generate "config.yaml" {
        password_file = config.sops.secrets."gomuks/password".path;
      };
    in
    {
      users.users.gomuks = {
        isSystemUser = true;
        group = "gomuks";
      };
      users.groups.gomuks = { };

      sops.secrets."gomuks/password" = {
        owner = "gomuks";
        sopsFile = ./secrets/${hostname}/gomuks.yaml;
      };

      systemd.services.gomuks = {
        name = "gomuks";
        serviceConifg = {
          User = "gomuks";
          ExecStart = "${cfg.package}";
          WorkingDirectory = "${cfg.dataDir}";
          Restart = "always";
          Environment = [
            "XDG_CONFIG_HOME=${cfgDir}"
          ];
        };
      };

      systemd.tmpfiles.rules = [
        "d ${cfgDir} 0700 ${cfg.user} ${cfg.user} -"
        "L+ ${cfgDir}/config.yaml - - - - ${configFile}"
      ];

    }
  );
}
