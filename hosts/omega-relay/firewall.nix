{ config, lib, pkgs, ... }:
let
  wgHomePort = 16888;
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
    wgHomePort # Wireguard
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
  sops.secrets = let 
	secrets = [
	  "wg/home/privateKey" 
	  "wg/home/chrono/PSK" 
	  "wg/home/chrono/PK" 
	  "wg/home/chrono/endpoint" 
	];  
  in lib.genAttrs secrets (name: {
	sopsFile = ../../secrets/${config.networking.hostName}/wireguard.yaml;
	key = lib.removePrefix "wg/" name; 
  });

  networking.wireguard = {
	enable = true; 
	useNetworkd = true; 
	interfaces = {
	  wg-home = {
	    ips = ["192.168.80.100/24"]; 
	    extraOptions = {
		DNS = "192.168.88.1"; 
	    };
	    privateKeyFile = config.sops.secrets."wg/home/privateKey".path; 
	    listenPort = wgHomePort;
	    dynamicEndpointRefreshSeconds = 45;
	    
	    peers = [
	      {
	        allowedIPs = ["192.168.88.0/24" "192.168.80.0/24"]; 
		presharedKeyFile = config.sops.secrets."wg/home/chrono/PSK".path;
		publicKey  = "rP5lJY6ea7BKX40edzqNMJbhfLkSlSwG1FipEufeflk="; 
	    	# endpoint       = "45.138.54.155:16556";
	    	endpoint       = "wilkuu.duckdns.org:16556";
		name = "wg-home-chronosphere"; 

	      } 
	    ]; 
	  }; 
	};
  }; 
  systemd.network.networks."40-wg-home".dns = ["192.168.88.1"];
  systemd.network.enable = true;
  systemd.network.networks."10-uplink" = {
    matchConfig.Name = "ens18";
    # TODO: Cloudinit
    address = ["45.136.141.133/26" "2a12:bec0:650:128::133/64"];   
    gateway = ["45.136.141.129"    "2a12:bec0:650:128::"];
    dns     = ["1.1.1.1"           "2606:4700:4700:0000:0000:0000:0000:1002"];
    linkConfig.RequiredForOnline="yes";
  };
  systemd.network.networks."99-fallback" = {
    matchConfig.Type = "ether";
    networkConfig.DHCP = "ipv4";
    linkConfig.RequiredForOnline="routable";
  };

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
