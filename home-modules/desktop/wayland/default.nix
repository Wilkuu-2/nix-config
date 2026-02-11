{
  pkgs,
  lib,
  hostconfig,
  ...
}:
{
  imports = [
    ./waybar.nix
    ./mako.nix
  ];
  xdg.portal = lib.mkIf hostconfig.addons.desktop.wayland.enable {
    enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

}
