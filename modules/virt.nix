{pkgs, config, lib, ...}: 
let 
  cfg = config.addons.virtualisation; 
in  
{
  options.addons.virtualisation = {
    host = lib.mkEnableOption "Allow to host vm's and containers"; 
    guest = lib.mkEnableOption "Enable guest agents"; 
  }; 

  config = lib.mkMerge([
    (lib.mkIf cfg.host {
      environment.systemPackages = with pkgs; [ 
        qemu 
      ]; 
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
      };   
      
    })
    (lib.mkIf cfg.guest {
      virtualisation.spiceUSBRedirection.enable = true; 
      services.spice-vdagentd.enable = true; 
    })
  ]);
} 
