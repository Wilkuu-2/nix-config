{ config,... }:
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
