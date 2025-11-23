{
  pkgs,
  ...
}:
{
  imports = [ ./user-common.nix ];
  programs.zsh.enable = true;
  users.users.live-user = {
    shell = pkgs.zsh;
    isNormalUser = true;
    initialPassword = "PleazeChangeThis123";
    extraGroups = [
      "wheel"
      "networkmanager"
      "input"
      "docker"
      "adbusers"
      "libvirtd"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      home-manager
    ];
  };

  home-manager.users.live-user = {
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
  };
}
