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
}
