
# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./services.nix
    ];



  nix.settings.experimental-features = ["nix-command" "flakes"]; 
  time.timeZone = "Europe/Amsterdam"; # Set timezone

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
   console = {
     font = "Lat2-Terminus16";
     keyMap = "us";
     # useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.zsh.enable = true;
   users.users.wilkuu = {
     shell = pkgs.zsh; 
     isNormalUser = true;
     extraGroups = [ "wheel" "networkmanager" "input" "docker" "adbusers" "libvirtd" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       tree
       home-manager
     ];
   };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";


  # programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
   environment.variables.EDITOR = "vim";
   # $ nix search wget
   environment.systemPackages = with pkgs; [
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     git 
     tmux 
     usbutils 
     lz4 
  ];


  
  # This option defines the first version of NixOS you have installed on this particular machine,  
  # DO NOT CHANGE UNLESS USING NIXOS-INSTALL

  system.stateVersion = "24.11"; # Did you read the comment?

}

