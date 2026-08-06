{ inputs, ... }: {
  omega-relay = {
    type = "server";
    system = "x86_64-linux";
    nix = true;
    nix-modules = [
      ./users/wilkuu-server.nix
      inputs.stalwart-nix.nixosModules.default
    ];
    monitoring = {
      internal = [
        "wireguard"
        "fail2ban"
        "node"
        "systemd"
        "unbound"
      ];
    };
    interfaces = {
      wg-home = {
        type = "wireguard";
        layer = "internal";
        ip = "192.168.80.100";
      };
      enp6s18 = {
        type = "eth-networkd";
        layer = "external";
        ip = "45.136.141.133";
        ip6 = "2a12:bec0:650:128::133/64";
      };
    };

  };
  apocalypse = {
    type = "desktop";
    system = "x86_64-linux";
    nix = true;
    nix-modules = [
      ./users/wilkuu.nix
    ];
    monitoring = {
      internal = [ "node" ];
    };
    interfaces = {
      nix-laptop = {
        type = "wireguard";
        layer = "internal";
        ip = "192.168.80.99";
      };
      wifi = {
        type = "roaming";
      };
      eth = {
        type = "roaming";
      };
    };
  };

  tacitus = {
    type = "desktop";
    system = "x86_64-linux";
    nix = true;
    nix-modules = [
      ./users/wilkuu-server.nix
    ];
    monitoring = {
      local = [
        "node"
        "mikrotik"
      ];
    };
    interfaces = {
      enp7s0 = {
        type = "eth-networkd";
        layer = "internal";
        ip = "192.168.88.5";
      };
      lo = {
        # A little workaround for not needing to go over the net to get own stats
        type = "roaming"; # TODO Set to something more sensible
        layer = "local";
        ip = "localhost";
      };
    };

  };
  # TODO: Support for live images as packages
  # full-iso = {
  #   type = "live";
  #  system = "x86_64-linux";
  #  nix = true;
  #  nix-paths = [
  #    ./users/live-user.nix
  #  ];
  #  interfaces = null;
  # };
}
