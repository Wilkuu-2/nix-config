{ config, pkgs, ... }:
{
  imports = [ ../home-modules ];

  homeapps = { 
    nvim.enable = true; 
    nvim.lsp = false;

    presets = {
      browser.enable = true;
      utils.enable = true;
    };
  };

  home.username = "live-user";
  home.homeDirectory = "/home/live-user";
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
