{pkgs, lib, ...}: {
  
  boot.loader.systemd-boot.enable = true; 
  boot.loader.efi.canTouchEfiVariables = true;

  addons.desktop.hyprland.enable = true; 
  addons.desktop.xfce.enable = true; 
  addons.virtualisation.guest = true; 
  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize = 2048; # Use 2048MiB memory.
      cores = 3;
      graphics = true;
    };
  };
}
