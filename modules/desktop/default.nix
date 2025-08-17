{pkgs, lib, config,...}: 
with lib; 
  let 
  wmMeta = config.addons.desktop.wmMeta; 

  # Gets all the vm's that are enabled and checks which protocols are used 
  enabledWMs = (filter (wm: wm.enable) (attrValues wmMeta));
  protos = (unique (map (wm: wm.protocol) enabledWMs)); 
  desktopEnabled = protos != []; 
  x11Enabled = elem "x11" protos; 
  waylandEnabled = elem "wayland" protos; 


in {
  imports = [
    ./common.nix
    ./x11.nix
    ./wayland.nix
    ./wms
  ];  
  options.addons.desktop = with types; {
      wmMeta = mkOption {
        type = attrsOf (submodule {
          options = {
            enable = mkOption {
              type = bool;
              default = false; 
            }; 
            protocol = mkOption {
              type = str;
              description = "Used display protocol (x11 or wayland)"; 
            }; 
          };
        });
        default = {}; 
        description = "Window manager metadata used for determining which protocol to enable.";
      };

      # enable = lib.mkEnableOption "Whenever any desktop environment is enabled."; 
      # x11.enable = lib.mkEnableOption "Whenever x11 desktop environment is enabled."; 
      # wayland.enable = lib.mkEnableOption "Whenever wayland desktop environment is enabled."; 
  };

  config.addons.desktop = { 
      enable = desktopEnabled; 
      x11.enable = x11Enabled; 
      wayland.enable = waylandEnabled; 
  };
}
