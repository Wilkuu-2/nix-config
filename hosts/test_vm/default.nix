{pkgs, lib, inputs,...}: {
  boot.loader.systemd-boot.enable = true; 
  boot.loader.efi.canTouchEfiVariables = true;
  imports = ["${inputs.nixpkgs}/nixos/modules/virtualisation/libvirtd.nix"];

  networking.hostName = "cookie_vm"; # Define your hostname.
  networking.networkmanager.enable = true; 
  programs.nix-ld.enable = true;


  addons.desktop.hyprland.enable = false; 
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
