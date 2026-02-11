{ lib, config, ... }:
{
  # TODO Make into option
  programs.kde-pim = lib.mkIf config.addons.desktop.enable {
    enable = true;
    kmail = true;
    merkuro = true;
    kontact = true;
  };
}
