
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

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true; 
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-lua
      fcitx5-mozc
      catppuccin-fcitx5 
      fcitx5-table-other
    ]; 
  }; 

  fonts.packages = with pkgs; [
	   noto-fonts
	   font-awesome
	   (nerdfonts.override {fonts = [ "Hermit" ]; })

	]; 
}
