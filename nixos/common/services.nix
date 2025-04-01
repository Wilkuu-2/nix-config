{config, lib, pkgs, ...}:
{

  ## VM's 
  programs.dconf.enable = true; 
  programs.virt-manager.enable = true;
  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true; 
        vhostUserPackages = with pkgs; [ virtiofsd ];
        ovmf.enable = true; 
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true; 
  };
  services.spice-vdagentd.enable = true; 

}
