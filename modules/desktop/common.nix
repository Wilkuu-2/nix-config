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
        plugins = with pkgs; [
          thunar-archive-plugin
          thunar-media-tags-plugin
          thunar-volman
        ];
      };
    };

    # Stuff that is useful for desktop environments.
    environment.systemPackages = with pkgs; [
      xdg-user-dirs
      zathura
      vlc
      mpv
      gparted
      kitty
      networkmanagerapplet
      (catppuccin-sddm.override {
        flavor = "mocha";
        accent = "pink";
        font = "Noto Sans";
        fontSize = "11";
        background = "${../sddm_bg.png}";
        loginBackground = true;
      })
    ];

    # Enable CUPS to print documents.
    # services.printing.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;

    services = {
      # TODO: Make it so bluetooth and audio are also toggleable.
      blueman.enable = true;
      # Enable sound
      pipewire = {
        enable = true;
        pulse.enable = true;
      };

      displayManager.sddm = {
        enable = true;
        theme = "catppuccin-mocha-pink";
      };
    };

    fonts.packages = with pkgs; [
      noto-fonts
      font-awesome
      nerd-fonts.hurmit
      minecraftia
    ];
  };
}
