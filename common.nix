{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./modules
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs = {
    config = {
      permittedInsecurePackages = [
        "olm-3.2.16"
      ];
      allowUnfree = true;
    };
  };
  time.timeZone = "Europe/Amsterdam"; # Set timezone

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;

  systemd.oomd = {
    enable = true;
    enableUserSlices = true;
    enableSystemSlice = true;
    enableRootSlice = true;
    extraConfig = {
      SwapUsedLimit = "50%";
      DefaultMemoryPressureLimit = "50%";
      DefaultMemoryPressureDurationSec = 20;

    };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  systemd.services.nix-daemon.serviceConfig = {
    MemoryAccounting = true;
    MemoryMax = "90%";
    OOMScoreAdjust = 500;
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

    # Needed for getting credentials
    age
    sops

    bashInteractive
    coreutils
    utillinux
    iproute2
    iputils
    pciutils
    usbutils
    vim

    # TODO: Dev stuff, move later
    # This could really make the image smaller
    git
    pkg-config
    cmake
    (hiPrio gcc)
    gnumake
    clang
    rustup
  ];

  networking.hosts = {
    "0.0.0.0" = [ "apresolve.spotify.com" ];
  };
  # This option defines the first version of NixOS you have installed on this particular machine,
  # DO NOT CHANGE UNLESS USING NIXOS-INSTALL
  system.stateVersion = "24.11"; # Did you read the comment?
}
