{pkgs, config, ...}: {
  programs.floorp = { 
    enable = true; 
    nativeMessagingHosts = [ pkgs.uget-integrator ]; 
  };

  home.packages = with pkgs; [
    uget
    uget-integrator 
  ];
}
