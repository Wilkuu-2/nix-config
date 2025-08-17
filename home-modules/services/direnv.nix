{pkgs, config, lib ,...}:
{
  options.homesv.direnv.enable = lib.mkEnableOption "Enable Direnv support"; 
  config = lib.mkIf config.homesv.direnv.enable { 
    programs.direnv = {
      enable = true; 
      enableZshIntegration = true;  
      nix-direnv.enable = true; 
    };
  };
}
