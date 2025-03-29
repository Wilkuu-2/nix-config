 {pkgs, config, ...}: 
 { 
   imports = [
     ./hardware-configuration.nix
     ../../common
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

  networking.hostName = "icetea-dispenser"; # Define your hostname.
  networking.firewall.enable = false;
  
  programs.nix-ld.enable = true;
  services.printing.enable = true;
  nixpkgs.config.allowUnfree = true; 
}
