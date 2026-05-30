{ ... }:
{
  imports = [ ../../services/mail2.nix ];
  wilkuu.services.test_endpoint = {
    enable = true;
    doACME = false;
    port = 9999;
    domain = "test.aperture.local";
  };
  
  wilkuu.services.mail = {
    enable = true;
    doACME = false;
    defaultDomain = "mail.aperture.local";
    domains = [ "mail.aperture.local" ];
    wellKnownDomains = [ "aperture.local" ];
    startupMode = "bootstrap";
  };

  lldap = {
    enable = false; 
    environmentFile = null; 
    settings = {
      
      
    }; 
  }; 
}
