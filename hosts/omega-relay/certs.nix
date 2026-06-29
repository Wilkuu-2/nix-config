{pkgs, config, lib, ...}: 
  let 
    names = [
      "moni.wilkuu.xyz"
      "matrix.wilkuu.xyz"
      "rss.wilkuu.xyz" 
      "bulwark.wilkuu.xyz"
      "uptime.wilkuu.xyz"
      "bitwarden.wilkuu.xyz"
      "wilkuu.xyz"
    ];
    in
{
  services.nginx.virtualHosts = lib.genAttrs names (name: {
    enableACME = lib.mkForce false; 
    useACMEHost = "wilkuu.xyz";
  }); 
} 
