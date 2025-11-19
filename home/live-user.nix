{ config, pkgs, ... }:
{
  imports = [ ../home-modules ];

  homeapps.presets = {
    browser.enable = true;
    utils.enable = true;
  };

  home.username = "live-user";
  home.homeDirectory = "/home/live-user";
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
