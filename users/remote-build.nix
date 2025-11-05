{pkgs, config, ...}: {

  sops.secrets.remote_pub = {
    key = "remote/ssh/pub"; 
    sopsFile = ../secrets/secrets.yaml;
  };
  users.users.remotebuild = {
    isSystemUser = true; 
    group = "remotebuild";
    useDefaultShell = true; 
    openssh.authorizedKeys.keyFiles = [ ../secrets/eli.pub ];
  };

  users.groups.remotebuild = {}; 
  nix.settings.trusted-users = [ "remotebuild" ]; 
}
