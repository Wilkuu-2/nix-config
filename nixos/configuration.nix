# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
      ./home-manager.nix
      ./services.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.grub = { 
        useOSProber = true;
   	device = "nodev";


	efiSupport = true;
	default = "saved";
	memtest86.enable = true;
	splashImage = ./GrubBG.png;
   };
   boot.loader.efi.canTouchEfiVariables = true;
   boot.crashDump.enable = false; 
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

  networking.hostName = "icetea-dispenser"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  programs.nix-ld.enable = true;

  services.printing.enable = true;
  documentation.dev.enable = true;
  services.displayManager.sddm ={
    #package = pkgs.kdePackages.sddm;
    enable = true;
    wayland.enable = true;
    theme="catppuccin-mocha";
  };
  services.xserver.exportConfiguration = true; # This makes it easy to search for a valid keymap 
  # Enable KDE6 env in case Hyprland gets borked. 
  # services.desktopManager.plasma6.enable = true;
  programs.hyprland.enable = true; 
  programs.hyprland.withUWSM  = true; 
  programs.uwsm = {
    enable = true; 
    waylandCompositors ={
      hyprland = {
        prettyName = "Hyprland";
        comment = "Hyprland compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/Hyprland";
      };
    };
  };

  nixpkgs.config.allowUnfree = true; 

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
   users.users.wilkuu = {
     isNormalUser = true;
     extraGroups = [ "wheel" "networkmanager" "input" "docker" "adbusers" "libvirtd" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       firefox
       nano
     ];
   };

  xdg.portal = {
     enable = true;
     config = {
        common = {
          default = [
            "hyprland"
            "gtk"
          ];
        }; 
     }; 
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
   environment.systemPackages = with pkgs; [
     zsh
     busybox
     usbutils
     libsForQt5.qtstyleplugins 
     xdg-desktop-portal-hyprland
     xdg-desktop-portal-gtk
     qt6.qtwayland
     #qt5.qtwayland
     kdePackages.sddm-kcm
     sddm
     # neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     nano
     wget
     git
     tree
     alacritty
     kitty
     docker
     home-manager
     wofi 
     waybar
     waybar-mpris
     vesktop
     wineWowPackages.waylandFull
     thunderbolt
     catppuccin-sddm
     kdePackages.kwallet
     kdePackages.kwalletmanager

     virt-viewer
     spice
     spice-gtk
     spice-protocol
     win-virtio
     win-spice
     gnome.adwaita-icon-theme
  ];

  environment.variables =  {
  	QT_STYLE_OVERRIDE = "kvantum";
    QT_QPA_PLATFORM="wayland";
    QT_QPA_PLATFORM_PATH="${pkgs.qt6.qtbase}/lib/qt-${pkgs.qt6.qtbase.version}/plugins/platform";
  };

  programs.adb.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
 
  # steam goes here
  programs.steam = {
    enable = true; 
    protontricks.enable = true; 
  };

 # Fonts 
fonts.packages = with pkgs; [
  noto-fonts
  noto-fonts-cjk-sans
  font-awesome
  noto-fonts-emoji
  # (nerdfonts.override {fonts = [ "Hermit" ];})
  nerdfonts
];
  
  # Input, note the waylandFrontend line  
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true; 
    fcitx5.waylandFrontend = true; 
    fcitx5.addons = with pkgs; [
        kdePackages.fcitx5-qt
        fcitx5-mozc
    ];
  }; 

 # Bluetooth 
  hardware.bluetooth.enable = true; 
  hardware.bluetooth.settings = {
	General = {Enable = "Source,Sink,Media,Socket";};  
  };

  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  services.avahi = {
    enable = true; 
    nssmdns = true; 
    publish = {
      enable = true;
    };
  };


   systemd.user.services.mpris-proxy = {
      description = "Mpris proxy";
      after = [ "network.target" "sound.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    };


    #services.fprintd.enable = true; 
    #security.pam.services.login.fprintAuth = true; 
  security.pam.services = {
        kdm.enableKwallet = true;
        lightdm.enableKwallet = true;
        sddm.enableKwallet = true;
        slim.enableKwallet = true;
      };

  programs.weylus = {
    enable=true; 
    openFirewall=true; 
    users=["wilkuu"];
  };

  ## VM's 
  programs.dconf.enable = true; 
  programs.virt-manager.enable = true;
  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true; 
        vhostUserPackages = with pkgs; [ virtiofsd ];
        ovmf.enable = true; 
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true; 
  };
  services.spice-vdagentd.enable = true; 
}
