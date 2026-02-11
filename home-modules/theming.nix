{
  hostconfig,
  pkgs,
  lib,
  ...
}:
let
  catppuccin_gtk = pkgs.catppuccin-gtk.override {
    accents = [ "pink" ];
    size = "compact";
    tweaks = [ "black" ];
    variant = "mocha";
  };
in
{
  config = lib.mkIf hostconfig.addons.desktop.enable {
    #Gtk Theming
    gtk = {
      enable = true;
      theme = {
        package = catppuccin_gtk;
        name = "catppuccin-mocha-pink-compact+black";
      };
      iconTheme = {
        package = pkgs.catppuccin-papirus-folders;
        name = "Papirus-Dark";
      };
    };

    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
      size = 32;
    };

    qt = {
      enable = true;
      kde.settings = {

      }; 
      style.package = pkgs.catppuccin-qt5ct;

      # style.name = "kvantum";
    };

    xdg.configFile."Kvantum/kvantum.kvconfig".source =
      (pkgs.formats.ini { }).generate "kvantum.kvconfig"
        {
          General.theme = "Catppuccin-Mocha-Pink";
        };
  };
}
