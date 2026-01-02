{ pkgs, lib, config, ...}: {
  imports = [
   ./firewall.nix
   ./vm.nix 
  ];

  addons = {
    desktop.hyprland.enable = lib.mkForce false; 
    desktop.xfce.enable = lib.mkForce false; 
    
    gpg.enable = true;
  };

  boot.loader.grub = {
    useOSProber = true;
  };

  networking.hostName = "omega-relay";  
  services.resolved = {
    enable = true; 
    dnsovertls = "opportunistic";
  };

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    openFirewall = true;
    allowSFTP = true;
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "wilkuu" ];
      X11Forwarding = false;
      PermitRootLogin = "no";
      PrintMotd = true;
    };
  };

  


  
}
