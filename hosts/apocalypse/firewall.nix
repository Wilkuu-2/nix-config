{ ... }:
let
  baseTCP = [
    22000 # Syncthng
    5352 # Zeroconf for spotifyd
    22 # ssh
  ];
  baseUDP = [
    22000 # Syncthing
    22027 # Syncthing
    16555 # Wireguard
    5353 # Mdns (Spotify)
  ];
  baseTCPRanges = [
    {
      from = 1714;
      to = 1764;
    } # KDE-CONNECT
  ];
  baseUDPRanges = [
    {
      from = 1714;
      to = 1764;
    } # KDE-CONNECT
  ];

  secureTCP = [
    80
    433
    5900 # SSH HTTP VNC
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
  wilkuu.firewall = {
    enable = true;
    defaultLayer = "external";
    layers = {
      internal = {
        allowedTCPPorts = secureTCP;
        allowedUDPPorts = secureUDP;
        allowedUDPPortRanges = secureUDPRanges;
        allowedTCPPortRanges = secureTCPRanges;
      };
      external = {
        allowedTCPPorts = baseTCP;
        allowedUDPPorts = baseUDP;
        allowedUDPPortRanges = baseUDPRanges;
        allowedTCPPortRanges = baseTCPRanges;
      };
    };
  };
  environment.etc.hosts.mode = "0644";
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [
      "docker0"
      "br-*"
      "veth*"
      "vnet*"
      "virbr*"
    ];

  };
}
