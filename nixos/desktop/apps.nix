{pkgs, ...} :
{
  environment.systemPackages = with pkgs; [
	neovim
	kitty
  ];

  programs.steam =  {
    enable = true; 
    protontricks.enable = true; 
    gamescopeSession.enable = true; 
  };
} 
