{
  config,
  pkgs,
  lib,
  ...
}:
let
  desktop = config.addons.desktop;
  cfg = config.addons.vpn;
  opt-mullvad = config.addons.vpn.mullvad;
in
{
  options.addons.vpn = {
    eduvpn.enable = lib.mkEnableOption "Enable eduvpn";
    fortissl.enable = lib.mkEnableOption "Enable fortissl";
    mullvad.enable = lib.mkEnableOption "Enable mullvad vpn";
  };

  config = lib.mkMerge [
    ({
      services.mullvad-vpn.enable = opt-mullvad.enable;
      services.mullvad-vpn.gui.enable = opt-mullvad.enable && desktop.enable;
    })
    (lib.mkIf cfg.eduvpn.enable {
      networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
    })
    (lib.mkIf cfg.fortissl.enable {
      networking.networkmanager.plugins = [
        pkgs.networkmanager-fortisslvpn
        pkgs.networkmanager-openconnect
      ];
      environment.systemPackages = with pkgs; [
        openfortivpn
        openfortivpn-webview
      ];
    })
    (lib.mkIf desktop.enable (
      lib.mkMerge [
        (lib.mkIf cfg.eduvpn.enable {
          environment.systemPackages = with pkgs; [
            eduvpn-client
          ];
        })
      ]
    ))
  ];
}
