{ pkgs, hostconfig, ... }:
{
  imports = [
    ./waybar.nix
    ./mako.nix
  ];
}
