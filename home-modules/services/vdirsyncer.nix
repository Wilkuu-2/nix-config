{pkgs, inputs, config, lib, ...}: 
let 
  cfg = config.homesv.vdirsyncer; 
in 
{ 
  options.homesv.vdirsyncer = {
    enable = lib.mkEnableOption "Enable syncing via vdirsyncer"; 
    user = lib.mkOption {  default = config.home.username; };
    server = lib.mkOption { default= "https://webdav.wilkuu.xyz/dav.php"; };
  };
  config = lib.mkIf cfg.enable {
    sops.secrets.webdav_uname = {
      sopsFile = ../../secrets/secrets.yaml;
      key="${cfg.user}/webdav/username";
    }; 
    sops.secrets.webdav_pass = {
      sopsFile = ../../secrets/secrets.yaml;
      key="${cfg.user}/webdav/password";
    }; 
    services.vdirsyncer = {
      enable = true; 
      frequency = "*:0/5"; # About once in 5 minutes
    }; 

    systemd.user.services.vdirsyncer.unitConfig.After = [ "sops-nix.service" ];
    
    sops.templates."vdirsyncer_config_${cfg.user}" = {
      content = ''
        [general]
        status_path = "~/.vdirsyncer/status/"

        [pair contacts] 
        a = "contacts_local"
        b = "contacts_remote"
        collections = ["from a", "from b"]

        [storage contacts_local] 
        type = "filesystem"
        path = "~/.contacts/"
        fileext = ".vcf" 

        [storage contacts_remote]
        type = "carddav"
        auth = "digest"
        url = "${cfg.server}"
        username = "${config.sops.placeholder.webdav_uname}"
        password = "${config.sops.placeholder.webdav_pass}"

        [pair calendar] 
        a = "calendar_local"
        b = "calendar_remote"
        collections = ["from a", "from b"]
        metadata = ["color", "displayname"]
        conflict_resolution = "b wins"

        [storage calendar_local] 
        type = "filesystem"
        path = "~/.calendar/"
        fileext = ".ics" 

        [storage calendar_remote]
        type = "caldav"
        auth = "digest"
        url = "${cfg.server}"
        username = "${config.sops.placeholder.webdav_uname}"
        password = "${config.sops.placeholder.webdav_pass}"
      '';
    };
    home.file.".config/vdirsyncer/config" = {
      source = config.lib.file.mkOutOfStoreSymlink config.sops.templates."vdirsyncer_config_${cfg.user}".path;
    };
  };
} 

