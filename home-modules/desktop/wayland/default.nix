{ pkgs, ... }:
{
  imports = [
    ./waybar.nix
    ./mako.nix
  ];
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

}
