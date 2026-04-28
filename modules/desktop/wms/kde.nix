{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.addons.desktop.kde;
in
{
  options.addons.desktop.kde = {
    enable = lib.mkEnableOption "Enable KDE";
  };

  config = lib.mkIf cfg.enable (
    {
      services = {
        desktopManager.plasma6.enable = true;
        displayManager.sddm.enable = true;
        displayManager.sddm.wayland.enable = true;
      };

      environment.systemPackages = with pkgs; [
        kdePackages.kcharselect # Character map
        kdePackages.kclock # Clock app
        kdePackages.kcolorchooser # Color picker
        kdePackages.ksystemlog # System log viewer
        kdePackages.sddm-kcm # SDDM configuration module
        kdiff3 # File/directory comparison tool

        # Hardware/System Utilities (Optional)
        hardinfo2 # System benchmarks and hardware info
        wayland-utils # Wayland diagnostic tools
        wl-clipboard # Wayland copy/paste support
      ];
      environment.plasma6.excludePackages = with pkgs; [
        kdePackages.konversation
        kdePackages.ktorrent
      ];
    }
    // (import ../../../utils/makeWm.nix "KDE" "wayland")
  );
}
