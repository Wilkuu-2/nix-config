{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
    ./testbed.nix
  ];

  boot.initrd.availableKernelModules = [
    "uhci_hcd"
    "ehci_pci"
    "ahci"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking = {
    useDHCP = true;
    hostName = "aperture";
    nftables.enable = true;
    useNetworkd = true;
  };

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
    };
  };

  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  boot.loader.limine = {
    efiSupport = true;
    enable = true;
    secureBoot = {
      enable = false;
    };
  };

    # SSH Access
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    openFirewall = true;
    allowSFTP = true;
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "wilkuu" ];
      X11Forwarding = true;
      PermitRootLogin = "no";
    };
  };


  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
