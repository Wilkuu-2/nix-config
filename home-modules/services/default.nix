{lib, ...}: {
   imports = [./direnv.nix]; 

  # Gnome keyring, very smort 
  services.gnome-keyring.enable = true;
} 
