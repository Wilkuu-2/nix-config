{
  pkgs,
  lib,
  hostconfig,
  ...
}:
{
  config = lib.mkIf hostconfig.addons.desktop.kde.enable {
    home.packages = with pkgs; [
      (catppuccin-kde.override {
        accents = [
          "pink"
          "mauve"
          "rosewater"
          "teal"
          "sky"
        ];
        flavour = [
          "mocha"
          "macchiato"
          "frappe"
          "latte"
        ];
      })
    ];
  };

}
