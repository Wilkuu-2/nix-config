{config, pkgs, lib, ...}: 
let
  desktop = config.addons.desktop;
  cfg = config.addons.vpn; 
  opt-mullvad = config.addons.vpn.mullvad; 
in  
{ 
  options.addons.vpn = {
    mullvad.enable = lib.mkEnableOption "Enable mullvad vpn";
  };

  config = lib.mkMerge [
    ({ services.mullvad-vpn.enable = opt-mullvad.enable; })
    (lib.mkIf desktop.enable (lib.mkMerge [ 
      (lib.mkIf opt-mullvad.enable {
        services.mullvad-vpn.package = pkgs.mullvad-vpn;
      })
    ])) 
  ];
}
