{pkgs, config, ...}:
let 
  baseTCP = [
    
  ]; 
  baseUDP = [
    16555 # Wireguard
  ]; 
  baseTCPRanges = [
    { from = 1714; to = 1764; } # KDE-CONNECT 
  ];
  baseUDPRanges = [
    { from = 1714; to = 1764; } # KDE-CONNECT 
  ];

  secureTCP = [
    22 80 433 5900
  ] ++ baseTCP;  
  
  secureUDP = [
    
  ] ++ baseUDP;  

  secureTCPRanges = [

  ] ++ baseTCPRanges ; 
  secureUDPRanges = [

  ] ++ baseUDPRanges; 
in 
{
    networking.firewall {
        enable = true; 
        allowedTCPPorts = baseTCP; 
        allowedUDPPorts = baseUDP; 
          allowedUDPPortRanges = baseUDPRanges;
          allowedTCPPortRanges = baseTCPRanges;
        interfaces = {
        "wg0" = {
          allowedTCPPorts = secureTCP; 
          allowedUDPorts = secureUDP; 
          allowedUDPPortRanges = secureUDPRanges;
          allowedTCPPortRanges = secureTCPRanges;
        };
    };
}

