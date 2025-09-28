{config, lib, ...}: 
{
  options.addons.lan-certs.enable = lib.mkDefault true;
  config = lib.mkIf config.addons.lan-certs.enable  {
    security.pki.certificateFiles = [../certs/wilkuu_ca.crt ];
  };
}
