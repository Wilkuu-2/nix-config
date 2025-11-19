{ modulesPath, pkgs, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  addons.desktop.hyprland.enable = true;
  addons.desktop.xfce.enable = false;
  addons.gpg.enable = false;
}
