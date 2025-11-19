{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.addons.desktop.enable = lib.mkEnableOption "On if the machine needs a desktop";

  config = lib.mkIf config.addons.desktop.enable {
    programs = {
      dconf.enable = true;
      thunar = {
        enable = true;
        plugins = with pkgs.xfce; [
          thunar-archive-plugin
          thunar-media-tags-plugin
          thunar-volman
        ];
      };
    };

    environment.systemPackages = with pkgs; [
      xdg-user-dirs
      zathura
      sioyek
      vlc
      mpv
      gparted
      kitty
      # qalculate
      networkmanagerapplet
      # disabled because it imports a unsafe package
      # surf # A basic browser in case we don't want to import a larger browser
    ];

    # Enable CUPS to print documents.
    # services.printing.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;

    services = {
      blueman.enable = true;
      # Enable sound
      pipewire = {
        enable = true;
        pulse.enable = true;
      };

      displayManager.sddm = {
        enable = true;
        #theme = "catppuccin-mocha";
      };

    };

    # fcitx is broken for now
    # i18n.inputMethod = {
    #   type = "fcitx5";
    #   enable = true;
    #   fcitx5.addons = with pkgs; [
    #     fcitx5-gtk
    #     fcitx5-lua
    #     fcitx5-mozc
    #     catppuccin-fcitx5
    #     fcitx5-table-other
    #     kdePackages.fcitx5-qt
    #   ];
    # };

    fonts.packages = with pkgs; [
      noto-fonts
      font-awesome
      nerd-fonts.hurmit
      minecraftia
    ];
  };
}
