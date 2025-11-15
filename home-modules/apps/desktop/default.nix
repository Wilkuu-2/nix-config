{lib, pkgs, config ,hostconfig, ...}: 
let 
  cfg = config.homeapps.presets; 
in 
{
  imports = [ 
    ./floorp.nix
  ];
  
  config = lib.mkIf hostconfig.addons.desktop.enable or false (lib.mkMerge [
    (lib.mkIf cfg.base.enable {
      home.packages = with pkgs; [
        # Base 
        evince
        kitty
        mpv
        #Theme  
        qt6Packages.qt6ct
        kdePackages.qtstyleplugin-kvantum
        (catppuccin-kvantum.override {
           accent = "pink";
           variant = "mocha";
        })

        nheko 
      ];
    })
    (lib.mkIf cfg.email.enable {
      home.packages = with pkgs; [
        thunderbird
      ];
    })
    (lib.mkIf cfg.comms.enable {
      home.packages = with pkgs; [
        element-desktop
        vesktop
      ];
    })
    (lib.mkIf cfg.utils.enable {
      home.packages = with pkgs; [
        kdePackages.filelight
        qalculate-qt
        gparted
      ];
    })
    (lib.mkIf cfg.note-taking.enable {
      home.packages = with pkgs; [ obsidian ];
      # Todo force synthing to be on here 
    })
    (lib.mkIf cfg.art.enable {
      home.packages = with pkgs; [
        krita 
        inkscape
      ];
    })
    (lib.mkIf cfg.browser.enable {
      home.packages = with pkgs; [
        librewolf
      ];
    })
    (lib.mkIf cfg.work.enable {
      home.packages = with pkgs; [
        libreoffice-qt6-fresh
        zotero
      ];
    })
    (lib.mkIf cfg.dev.enable {
      home.packages = with pkgs; [
        hugo
        wireshark-qt
      ];
    })
    (lib.mkIf cfg.connectivity.enable {
      home.packages = with pkgs; [
        kdePackages.kdeconnect-kde
        eduvpn-client 
      ];
      services.syncthing = { 
        tray = {
          enable = true; 
          command = "syncthingtray --wait"; 
        }; 
      };
    })
    (lib.mkIf cfg.multimedia.enable {
      home.packages = with pkgs; [
        ani-cli
        vlc
        # Spotify (The proprietary frontend)
        riff 
      ];
    })
    (lib.mkIf cfg.games.enable {
      home.packages = with pkgs; [
        # Games 
        prismlauncher
        openttd
        anki-bin
      ];
    })
  ]);
}
