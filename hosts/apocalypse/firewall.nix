{pkgs, config, ...}:
let 
  baseTCP = [
    22000 # Syncthng
  ]; 
  baseUDP = [
    22000 # Syncthing
    22027 # Syncthing 
    16555 # Wireguard
  ]; 
  baseTCPRanges = [
    { from = 1714; to = 1764; } # KDE-CONNECT 
  ];
  baseUDPRanges = [
    { from = 1714; to = 1764; } # KDE-CONNECT 
  ];

  secureTCP = [
    22 80 433 5900 # SSH HTTP VNC
  ];  
  
  secureUDP = [
    5900 
  ];  

  secureTCPRanges = [

  ]; 
  secureUDPRanges = [

  ]; 
in 
{
    networking.firewall = {
        enable = false; 
        allowedTCPPorts = baseTCP; 
        allowedUDPPorts = baseUDP; 
          allowedUDPPortRanges = baseUDPRanges;
          allowedTCPPortRanges = baseTCPRanges;
        interfaces = {
          "nix-laptop" = {
            allowedTCPPorts = secureTCP; 
            allowedUDPPorts = secureUDP; 
            allowedUDPPortRanges = secureUDPRanges;
            allowedTCPPortRanges = secureTCPRanges;
          };
       };
    };
}

