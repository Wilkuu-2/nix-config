{lib, pkgs, ...}:
with lib;
{
   imports = [
     ./nvim
     ./desktop 
     ./zsh.nix
   ];

   # Stuff that is to be sorted to its appropriate files
   # If no appropriate category is found or thought of, put it in misc.nix
   home.packages = with pkgs; [
	speedcrunch
	htop
	btop 
	nmap 
	dig
	ripgrep 
	unzip 
	unrar
	xdg-user-dirs
	thunderbird
	element-desktop 
	filelight
	libreoffice 
	evince
	obsidian
	krita 
	hugo
	qalculate-qt
	
	spotify
	prismlauncher
	ani-cli
	vlc
	mpv
	openttd
	anki-bin

	#Theme  
	qt6Packages.qt6ct
	kdePackages.qtstyleplugin-kvantum
	(catppuccin-kvantum.override {
	   accent = "pink";
	   variant = "mocha";
	})


	# Do i need this? 
	php 
	php83Packages.composer

   ]; 
}
