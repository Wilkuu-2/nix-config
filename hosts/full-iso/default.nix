{ modulesPath, lib, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.hardware.bolt.enable = true;
  powerManagement.enable = true;

  networking.useDHCP = lib.mkDefault true;

  networking.hostName = "conscript-live"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };

  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  addons.desktop.hyprland.enable = false;
  addons.desktop.xfce.enable = true;
  addons.gpg.enable = false;
}
