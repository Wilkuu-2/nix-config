{ ... }:
let
  baseTCP = [
    20
    22
    25
    80
    443
  ];
  baseUDP = [
  ];
  baseTCPRanges = [ ];
  baseUDPRanges = [ ];
in
{
  systemd.network = {
    enable = true;
    networks."10-uplink" = {
      matchConfig.Type = "ether";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = "yes";
      };
      linkConfig = {
        RequiredForOnline = "yes";
      };
      ipv6AcceptRAConfig = {
        UseDNS = "yes";
        UseDomains = "yes";
      };
      dns = [
        "192.168.88.1"
        "1.1.1.1"
        "2606:4700:4700:0000:0000:0000:0000:1002"
      ];
    };
  };
  networking = {
    useNetworkd = true;
    nftables.enable = true;
    useDHCP = true;
    firewall = {
      # check  enable = true;
      checkReversePath = false;
      allowedTCPPorts = baseTCP;
      allowedUDPPorts = baseUDP;
      allowedUDPPortRanges = baseUDPRanges;
      allowedTCPPortRanges = baseTCPRanges;
      # TODO: Figure out how to do FW that allows only on the internal ip range
      #interfaces = {
      #  "wg-home" = {
      #   allowedTCPPorts = secureTCP;
      #   allowedUDPPorts = secureUDP;
      #   allowedUDPPortRanges = secureUDPRanges;
      #   allowedTCPPortRanges = secureTCPRanges;
      # };
      #};
    };
  };

}
