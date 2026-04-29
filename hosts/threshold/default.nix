{
  lib,
  ...
}:
{

  imports = [
    ./network.nix
    ./disko.nix
    ./hardware.nix
  ];
  addons = {
    desktop.xfce.enable = lib.mkForce true;
    gpg.enable = true;
    virtualisation.host = true;
  };

  # Bootloader and boot setup.
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  boot.loader.grub = {
    enable = true;
    useOSProber = false;
    device = "nodev";
    efiSupport = true;
    default = "saved";
    memtest86.enable = true;
  };

  # Networking setup
  networking.hostName = "threshold";
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
