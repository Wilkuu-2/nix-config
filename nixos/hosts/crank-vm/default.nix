{ config, inputs, pkgs, ...}: 
{
	imports = [
	   ./hardware-configuration.nix
	   ../../common
	];
	
  	networking.hostName = "crank-vm"; # Define your hostname.
	# Use the systemd-boot EFI boot loader.
	# boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true; 
	boot.loader.grub =  { 
	  device = "nodev";
	  useOSProber = true;
	  efiSupport = true; 
	  default = "saved";
	  memtest86.enable = true; 
	};
 	 networking.firewall.enable = false;
}
