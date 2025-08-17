{pkgs, lib, ...}: {
  imports = [
    ./modules
  ]; 

  nix.settings.experimental-features = ["nix-command" "flakes"]; 
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  time.timeZone = "Europe/Amsterdam"; # Set timezone

  systemd.oomd = {
    enable = true;
    enableUserSlices = true;
    enableRootSlice = true;
  };

  nix.gc = {
    automatic = true; 
    dates = "weekly"; 
    options = "--delete-older-than 30d";
  };

  environment.systemPackages = with pkgs; [
    htop
    btop 
    nmap 
    dig
    ripgrep 
    unzip 
    sshfs
    ranger
    file
    lm_sensors 
  
    bashInteractive
    coreutils
    utillinux
    iproute2
    iputils
    pciutils 
    usbutils
    vim

    # Dev stuff, move later
    git
    pkg-config
    cmake 
    ( hiPrio gcc)
    gnumake
    clang
    rustup
  ];
  
  # This option defines the first version of NixOS you have installed on this particular machine,  
  # DO NOT CHANGE UNLESS USING NIXOS-INSTALL
  system.stateVersion = "24.11"; # Did you read the comment?
} 
