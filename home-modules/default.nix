{pkgs, config ,...}: {
  imports = [./theming.nix ./apps ./desktop ./services ];

  sops = {
    age.keyFile = "/home/${config.home.username}/.config/sops/age/keys.txt"; 
    defaultSopsFile = ../secrets/secrets.yaml; 
  };

} 
