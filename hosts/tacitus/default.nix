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
  nix.settings.trusted-users = [ "wilkuu"];
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
