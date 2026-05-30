{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./backup.nix
    ./firewall.nix
    ../../services/mail2.nix
  ];

  ## TODO REMOVE LATER TO PREVENT ELI FROM BUILDING REMOTELY
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  networking.hosts = {
    "127.0.0.1" = [ "apocalypse.local" ];
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "ignore";
  };

  wilkuu.services.test_endpoint.enable = false;
  wilkuu.services.mail = {
    enable = true;
    doACME = false;
    defaultDomain = "apocalypse.local";
    domains = [ "apocalypse.local" ];
    wellKnownDomains = [ ];
    startupMode = "bootstrap";
  };

  ## Addons for this system
  addons = {
    desktop.hyprland.enable = false;
    desktop.xfce.enable = true;
    desktop.cosmic.enable = true;
    desktop.kde.enable = true;
    steam.enable = true;

    virtualisation.guest = false;
    virtualisation.host = true;

    vpn.mullvad.enable = true;
    vpn.eduvpn.enable = true;
    vpn.fortissl.enable = true;
    gpg.enable = true;

    remote_builder = {
      enable = true;
      allowedKeyFiles = [
        ../../secrets/omega-relay_hostkey_ed25519.pub
        ../../secrets/remotebuild.pub
        ../../secrets/eli.pub
      ];
      openFirewall = true;
    };
  };

  boot.loader.grub = {
    useOSProber = true;
    device = "nodev";

    efiSupport = true;
    default = "saved";
    memtest86.enable = true;
    # splashImage = ./GrubBG.png;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.crashDump.enable = true;
  boot.plymouth = {
    enable = true;
    theme = "bgrt";
  };

  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.logpriority=3"
  ];
  boot.consoleLogLevel = 0;

  networking.hostName = "apocalypse"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };

  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  programs.nix-ld.enable = true;
  services.printing.enable = true;

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "false";
      Domains = [ "~." ];
      FallbackDns = [ "8.8.8.8" ];
      DNSOverTLS = "opportunistic";
    };
  };

  networking.useDHCP = lib.mkDefault true;
  networking.firewall.checkReversePath = false;

  # Thunderbolt
  services.hardware.bolt.enable = true;
  powerManagement.enable = true;

  # Firmware updates
  services.fwupd.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    openFirewall = false;
    allowSFTP = false;
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "wilkuu" ];
      X11Forwarding = false;
      PermitRootLogin = "no";
      PrintMotd = true;
    };
  };

  services.thinkfan = {
    enable = true;
    levels = [
      [
        0
        0
        55
      ]
      [
        1
        48
        60
      ]
      [
        2
        50
        65
      ]
      [
        3
        55
        67
      ]
      [
        4
        56
        68
      ]
      [
        5
        60
        70
      ]
      [
        6
        65
        72
      ]
      [
        7
        66
        85
      ]
      [
        "level disengaged"
        84
        32767
      ]
    ];
  };
}
