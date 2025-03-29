{ config, pkgs, ... }:

{
  imports = [ ./hyprland.nix ./syncthing.nix ./theming.nix ./neovim.nix ./xdg.nix];  
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (import ./electron_overlay.nix)
    # (import (builtins.fetchTarball {
    #     url = "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
    #   }))
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "wilkuu";
  home.homeDirectory = "/home/wilkuu";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Environment
    hyprpolkitagent
    hyprsunset
    xdg-desktop-portal-kde
    xdg-desktop-portal-hyprland
    minecraftia
    inconsolata-nerdfont
    # Utils 
    networkmanagerapplet
    blueman
    htop
    pwvucontrol
    wl-clipboard
    xdg-user-dirs
    hyprshot
    mako
    speedcrunch
    unzip 
    ripgrep
    glib
    gwenview

    # Connectivity 
    firefox 
    floorp
    thunderbird
    element-desktop
    
    # File management 
    pcmanfm
    xarchiver
    filelight
    ranger
    libsForQt5.kdeconnect-kde
    sshfs

    #Productivity
    libreoffice-qt6-fresh
    zathura
    obsidian
    
    # Artistic 
    krita 
    kdenlive

    # Web
    hugo

    # Scripting
    python3

    # php 
    php83Packages.composer
    php

    # java
    openjdk17-bootstrap
    gradle
    
    # Shell 
    zsh
    alacritty

    # Entertainment 
    spotify
    prismlauncher
    ani-cli
    vlc
    openttd
    fluent-reader

    # Finance
    gnucash
    # SRS 
    anki-bin
    mpv

    # Electronics 
    
    gst_all_1.gstreamer
    # Common plugins like "filesrc" to combine within e.g. gst-launch
    gst_all_1.gst-plugins-base
    # Specialized plugins separated by quality
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    # Plugins to reuse ffmpeg to play almost every video format
    gst_all_1.gst-libav
    # Support the Video Audio (Hardware) Acceleration API
    gst_all_1.gst-vaapi

    #Theme  
    qt6Packages.qt6ct
    kdePackages.qtstyleplugin-kvantum
     (catppuccin-kvantum.override {
          accent = "pink";
          variant = "mocha";
        })


    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/wilkuu/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
     EDITOR = "nvim";
     XDG_SESSION_TYPE = "wayland";
     GDK_BACKEND = "wayland";
     GTK_USE_PORTAL = "1";
     QT_QPA_PLATFORM = "wayland";
     QT_STYLE_OVERRIDE = "kvantum";
     QT_QPA_PLATFORM_THEME = "kvantum";
     QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
     QT_AUTO_SCREEN_SCALE_FACTOR = "1";
     MOZ_ENABLE_WAYLAND = "1";
  };


  programs.zsh = {
    enable = true; 
    enableCompletion = true;
    oh-my-zsh = {
      enable = true; 
      theme = "clean";
    };
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
    ];
  }; 
  

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}
