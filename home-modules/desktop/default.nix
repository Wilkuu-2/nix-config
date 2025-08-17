{pkgs, hostconfig, ...}: {
  imports = [./wayland ./hyprland.nix];

}
