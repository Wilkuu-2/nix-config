 {pkgs, config, lib, ...}: 
 { 
   imports = [
     ./hardware-configuration.nix
     ../../common
     ./nvidia.nix
     ./backup.nix
     ./firewall.nix
   ];
   boot.loader.grub = { 
        useOSProber = true;
   	device = "nodev";


	efiSupport = true;
	default = "saved";
	memtest86.enable = true;
	# splashImage = ./GrubBG.png;
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

  networking.hostName = "apocalypse"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  
  hardware.bluetooth.enable = true; 
  hardware.bluetooth.settings = {
	General = {Enable = "Source,Sink,Media,Socket";};  
  };

  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  programs.nix-ld.enable = true;
  services.printing.enable = true;
  nixpkgs.config.allowUnfree = true; 


	services.resolved = {
	  enable = true;
	  dnssec = "false";
	  domains = [ "~." ];
	  fallbackDns = [ ];
	  dnsovertls = "opportunistic";
	};

  
  networking.useDHCP = lib.mkDefault true;
  networking.firewall.checkReversePath = false;  


  # Thunderbolt 
  services.hardware.bolt.enable = true;
  powerManagement.enable = true; 

  # Firmware updates 
  services.fwupd.enable = true; 
}


