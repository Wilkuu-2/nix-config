{
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./user-common.nix ];
  programs.zsh.enable = true;
  users.users.wilkuu = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keyFiles = [
      ../certs/wilkuu_rsa.pub
      ../certs/pi_ed25519.pub
    ];
    isNormalUser = true;
    initialPassword = "PleazeChangeThis123";
    extraGroups = [
      "wheel"
      "adbusers"
      "networkmanager"
      "input"
      "docker"
      "adbusers"
      "libvirtd"
      "libvirt"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      home-manager
    ];
  };

  home-manager.users.wilkuu = {
    imports = [ ../home-modules ];

    homeapps.presets = lib.genAttrs [ "base" "utils" "browser" ] (_: {
      enable = true;
    });
    # homeapps.vnc = true;

    # services.wayvnc = {
    #   enable = true;
    #   autoStart = false;
    #   settings = {
    #     # Todo, bind to vpn and LAN explicitly somehow
    #     address = "0.0.0.0";
    #     port = 5900;
    #   };
    # };

    home.username = "wilkuu";
    home.homeDirectory = "/home/wilkuu";
    home.stateVersion = "24.11";
    programs.home-manager.enable = true;
  };

}
