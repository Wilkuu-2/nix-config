{pkgs, config}: {
  programs.floorp = { 
    enabled = true; 
    nativeMessagingHosts = [ pkgs.uget-integrator ]; 
  };

  home.packages = with pkgs; [
    uget
  ];
}
