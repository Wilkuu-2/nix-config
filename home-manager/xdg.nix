{ config, pkgs, ... }:
{
  xdg.mimeApps.defaultApplications = {
    "application/zip" = [ "xarchiver.desktop" ];
    "application/x-krita" = [ "krita.desktop" ];
    "image/*" = [ "gwenview.desktop" "krita.desktop"];
    "inode/directory" = [ "pcmanfm.desktop" "filelight.desktop" "kitty.desktop"];
  };
}
