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
	htop
	btop 
	nmap 
	dig
	ripgrep 
	unzip 
	unrar
	xdg-user-dirs
	zsh
	cmake 
	( hiPrio gcc)
	clang
	rustup

	# Do i need this? 
	php 
	php83Packages.composer

  ]; 
}
