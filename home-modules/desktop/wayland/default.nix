{ pkgs, ... }:
{
  imports = [
    ./waybar.nix
    ./mako.nix
  ];
  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

}
