{lib, ...}: {
   imports = [./vdirsyncer.nix ./direnv.nix ./syncthing.nix];

  # Gnome keyring, very smort 
  services.gnome-keyring.enable = true;
} 
