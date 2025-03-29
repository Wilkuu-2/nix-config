
{pkgs, ...}:
{
	imports = [
	   ./apps.nix
           ./xfce.nix
	   ./hyprland.nix
	]; 

	programs = {
	   dconf.enable = true; 
           thunar = {
	   	enable = true; 
                plugins = with pkgs.xfce; [
		    thunar-archive-plugin
                    thunar-media-tags-plugin
		    thunar-volman
		];
           };
	};
	  # Enable CUPS to print documents.
	  services.printing.enable = true;


	  # Enable touchpad support (enabled default in most desktopManager).
	  services.libinput.enable = true;
	
	services = {
	   blueman.enable = true; 
	   # Enable sound 
     pipewire = {
	       enable = true; 
	       pulse.enable = true; 
     };

	   displayManager.sddm = {
		enable=true; 
		wayland.enable = true;
		#theme = "catppuccin-mocha";
           };
	   xserver = {
	      enable = true; 
	      excludePackages = with pkgs; [
	    	xterm
              ];
	   };
	};

        fonts.packages = with pkgs; [
	   noto-fonts
	   font-awesome
	   (nerdfonts.override {fonts = [ "Hermit" ]; })
	]; 
}
