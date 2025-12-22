{ ... }:
let
  baseTCP = [
    22000 # Syncthng
    5352 # Zeroconf for spotifyd
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
    22
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
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    checkReversePath = false;
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
    trustedInterfaces = [
      "docker0"
      "br-*"
      "veth*"
      "vnet*"
      "virbr*"
    ];

  };
}
