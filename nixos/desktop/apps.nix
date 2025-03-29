{pkgs, ...} :
{
  environment.systemPackages = with pkgs; [
	floorp
	neovim
	kitty
  ];
} 
