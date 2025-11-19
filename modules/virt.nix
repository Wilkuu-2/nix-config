{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.addons.virtualisation;
in
{
  options.addons.virtualisation = {
    host = lib.mkEnableOption "Allow to host vm's and containers";
    guest = lib.mkEnableOption "Enable guest agents";
  };

  config = lib.mkMerge ([
    (lib.mkIf cfg.host {
      environment.systemPackages = with pkgs; [
        qemu
      ];
      programs.virt-manager.enable = true;
      virtualisation = {
        spiceUSBRedirection.enable = true;
        docker.enable = true;
        libvirtd = {
          enable = true;
          qemu = {
            swtpm.enable = true;
            vhostUserPackages = with pkgs; [ virtiofsd ];
          };
        };
      };

    })
    (lib.mkIf cfg.guest {
      services.spice-vdagentd.enable = true;
    })
  ]);
}
