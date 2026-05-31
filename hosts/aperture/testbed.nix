{ config, pkgs, lib, ... }: let 
    dotsToDn = type: domain: (lib.concatMapStringsSep ","  (x: "${type}=${x}") (lib.splitString "." domain));
    baseDN = dotsToDn "dc" "aperture.local";
    sopsCred = name: config.sops.secrets."lldap/${name}".path; 
in 
{
  imports = [ ../../services/mail2.nix ];
  wilkuu.services.test_endpoint = {
    enable = true;
    doACME = false;
    port = 9999;
    domain = "test.aperture.local";
  };
  
  # systemd.services.stalwart.serviceConfig.Environment = ["STALWART_PUBLIC_URL=http://mail.aperture.local"];
  wilkuu.services.mail = let 
      domain_to_jid = lib.replaceString "." "_";
  in {
    enable = true;
    doACME = false;
    defaultDomain = "mail.aperture.local";
    domains = [ "aperture.local" ];
    wellKnownDomains = [];
    startupMode = "recovery";
    extraCreate = []; 
    extraConfig = []; 
  };
  
  users.users.lldap = {
    isSystemUser = true;
    group = "lldap"; 
  };
  users.groups.lldap = {};

  sops.secrets = let 
    sopsPath = ../../secrets/${config.networking.hostName}/lldap.yaml;
    secrets  = ["admin_password" "jwt_secret"];
    toSops = (sname: "lldap/${sname}"); 
  in lib.genAttrs (map toSops secrets) ( _name: {
    sopsFile = sopsPath; 
    mode = "0440";
    owner = "lldap";
  }); 
  
  services.nginx.virtualHosts."ldap.aperture.local" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.lldap.settings.http_port}";
      recommendedProxySettings = true; 
    };
  }; 

  networking.firewall.allowedTCPPorts = [ 80 ];

  services.lldap = let 

  in {
    enable = true; 
    # environmentFile = null; 
    settings = {
      force_ldap_user_pass_reset = "always"; 
      jwt_secret_file      = sopsCred "jwt_secret";  
      ldap_user_pass_file  = sopsCred "admin_password"; 
      ldap_user_dn         = "ldap_admin";  
      ldap_user_email      = "ldap_admin@aperture.local"; 

      ldap_base_dn         = baseDN;  
      ldap_port            = 3890; 
      
      http_url             = "http://ldap.aperture.local"; 
    }; 
  }; 
}
