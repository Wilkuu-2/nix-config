{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.wilkuu.mjmap;
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
  # TODO: Once the mjmap patch is upstreamed, use this.
  #mjmap_wrap = (pkgs.writeScriptBin "mjmap" ''
  #  #! ${pkgs.bash}/bin/bash
  #  export MJMAP_CONFIG=${config.sops.secrets."mjmap-creds".path};
  #  exec ${pkgs.mjmap} "$@"
  # '');

  # Workaround since the current version does not support setting config path;
  mjmap_wrap = (
    pkgs.writeScriptBin "mjmap-send" ''
      #! ${pkgs.bash}/bin/bash
      export XDG_CONFIG_DIR=/etc/;
      exec ${pkgs.mjmap}/bin/mjmap "$@"
    ''
  );

  sendmail_wrap = pkgs.symlinkJoin {
    name = "sendmail-wrapper";
    paths = [ mjmap_wrap ];
    postBuild = ''
      ln -s $out/bin/mjmap-send $out/bin/sendmail
    '';
  };

in
{
  options.wilkuu.mjmap = {
    enable = mkEnableOption "mjmap jmap email";
    users = mkOption {
      type = types.listOf types.str;
      description = "users that are allowed to view the credentials file and thus use mjmail";
    };
  };

  config = mkIf cfg.enable {
    users.groups.mjmap = mkIf (cfg.users != [ ]) { };
    users.users = lib.genAttrs cfg.users (_: {
      extraGroups = [ "mjmap" ];
      packages = [
        mjmap_wrap
        sendmail_wrap
      ];
    });
    sops.secrets."mjmap-creds" = mkIf (cfg.users != [ ]) {
      sopsFile = ../secrets/${config.networking.hostName}/mjmap.scfg.bin;
      key = "";
      format = "binary";
      group = "mjmap";
      mode = "440";
    };
    environment.etc."mjmap/config.scfg" = mkIf (cfg.users != [ ]) {
      source = config.sops.secrets."mjmap-creds".path;
    };
    environment.systemPackages = [ pkgs.mjmap ];
  };
}
