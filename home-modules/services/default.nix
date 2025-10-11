{lib, ...}: {
   imports = [./direnv.nix ./syncthing.nix];

  # Gnome keyring, very smort 
  services.gnome-keyring.enable = true;
} 
