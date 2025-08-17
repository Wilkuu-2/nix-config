{pkgs, lib, config, ...}: {
  options.addons.desktop.x11.enable = lib.mkEnableOption "Enabled if X11 is needed for this machine";
  config = lib.mkIf config.addons.desktop.x11.enable {
    services.xserver = {
        enable = true; 
        excludePackages = with pkgs; [
          xterm
        ];
     };
  }; 
}
