{ ... }:
let
  baseTCP = [
    20
    22
    25
    80
    143
    443
    993
    465
  ];
  baseUDP = [
    16555 # Wireguard
  ];
  baseTCPRanges = [
  ];

  baseUDPRanges = [
  ];

  secureTCP = [
    # config.wilkuu.services.mysql.port
  ];

  secureUDP = [
  ];

  secureTCPRanges = [
  ];

  secureUDPRanges = [
  ];
in
{
  systemd.network.enable = true;
  systemd.network.networks."10-uplink" = {
    matchConfig.Name = "eth*";
    networkConfig.DHCP = "ipv4";
    linkConfig.RequiredForOnline="routable";
  };
  systemd.network.networks."99-fallback" = {
    matchConfig.Type = "ether";
    networkConfig.DHCP = "ipv4";
    linkConfig.RequiredForOnline="routable";
  }

  networking.useDHCP = false;
  networking.useNetworkd = true;
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    checkReversePath = false;
    allowedTCPPorts = baseTCP;
    allowedUDPPorts = baseUDP;
    allowedUDPPortRanges = baseUDPRanges;
    allowedTCPPortRanges = baseTCPRanges;
    interfaces = {
      "wg-home" = {
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
      "lo"
    ];

  };
}
