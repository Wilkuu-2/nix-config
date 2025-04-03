{pkgs, ...} :
{
  environment.systemPackages = with pkgs; [
	floorp
	neovim
	kitty
  ];

  programs.steam =  {
    enable = true; 
    protontricks.enable = true; 
    gamescopeSession.enable = true; 
  };
} 
