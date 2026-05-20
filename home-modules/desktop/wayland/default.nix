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
    configPackages = lib.mkIf hostconfig.addons.desktop.kde.enable [ pkgs.kdePackages.plasma-desktop ];
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-cosmic
    ];
  };

}
