{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.addons.gpg;
in
{
  options.addons.gpg = {
    enable = lib.mkEnableOption "Allow gpg for all users";
  };

  config = lib.mkMerge ([
    (lib.mkIf cfg.enable {
      programs.gnupg = {
        agent = {
          enable = true;
          pinentryPackage =
            if (config.addons.desktop.kde.enable) then
              lib.mkForce pkgs.pinentry-qt
            else
              lib.mkForce pkgs.pinentry-gtk2;
        };
      };
    })
  ]);

}
