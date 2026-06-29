{
  lib,
  config,
  ...
}:
{
  imports = [
    ./network.nix
    ./disko.nix
    ./hardware.nix
  ];

  wilkuu.services = {
    prometheus.enableScraper = true;
    prometheus.enableExporters = true;
  };

  addons = {
    desktop.xfce.enable = lib.mkForce true;
    gpg.enable = true;
    virtualisation.host = true;
  };
  nix.settings.trusted-users = [ "wilkuu" ];
  # Bootloader and boot setup.
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  boot.loader.limine = {
    efiSupport = true;
    enable = true;
    secureBoot = {
      enable = true;
      autoGenerateKeys = true;
      autoEnrollKeys = {
        extraArgs = [
          "--microsoft"
          "--firmware-builtin"
        ];
      };
    };
  };

  boot.initrd.systemd.enable = true;
  users.users.wilkuu.extraGroups = [ "tss" ];

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;
  security.tpm2.tctiEnvironment.enable = true;
  # Networking setup
  networking.hostName = "tacitus";
  services.resolved = {
    enable = true;
    settings.Resolve.DNSOverTLS = "opportunistic";
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
  users.groups.mikrotik-exporter = { };
  users.users.mikrotik-exporter = {
    isSystemUser = true;
    group = "mikrotik-exporter";
  };

  # TODO: "Make each device hold it's own password."
  sops.secrets."prometheus/mikrotik/username" = {
    owner = "mikrotik-exporter";
    sopsFile = ../../secrets/tacitus/prometheus.yaml;
  };
  sops.secrets."prometheus/mikrotik/password" = {
    owner = "mikrotik-exporter";
    sopsFile = ../../secrets/tacitus/prometheus.yaml;
  };

  sops.templates."prometheus-mikrotik-config" = {
    owner = "mikrotik-exporter";
    content = lib.generators.toYAML {} {
      devices = [
        {
          name = "chronosphere";
          address = "192.168.88.1";
          user = config.sops.placeholder."prometheus/mikrotik/username";
          password = config.sops.placeholder."prometheus/mikrotik/password";
        }
        {
          name = "geneticmutator";
          address = "192.168.88.2";
          user = config.sops.placeholder."prometheus/mikrotik/username";
          password = config.sops.placeholder."prometheus/mikrotik/password";
        }

      ];
      features = {
        dhcp = true;
        dhcpv6 = true; 
        optics = true;
        health = true;
        poe = true;
        wlansta = true;
        wlanif = true;
        monitor=true;
        routes = true; 
        firware = true; 
        netwatch = true;
        conntrack = true;
      };
    };
  };

  services.prometheus.exporters.mikrotik = {
    enable = true;
    group = "mikrotik-exporter";
    user = "mikrotik-exporter";
    configFile = config.sops.templates.prometheus-mikrotik-config.path;
  };
}
