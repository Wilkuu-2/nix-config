{lib, pkgs, ...}: with lib; {
  imports = [ ./hyprland.nix ];

  home.packages = with pkgs; [	
    speedcrunch
    thunderbird
    element-desktop 
    filelight
    libreoffice 
    evince
    obsidian
    krita 
    hugo
    qalculate-qt
    libsForQt5.kdeconnect-kde
    libreoffice-qt6-fresh
    obsidian
    krita
    kitty
    make
    zotero
    
    spotify
    prismlauncher
    ani-cli
    vlc
    mpv
    openttd
    anki-bin
    vesktop

    #Theme  
    qt6Packages.qt6ct
    kdePackages.qtstyleplugin-kvantum
    (catppuccin-kvantum.override {
       accent = "pink";
       variant = "mocha";
    })
  ];
}
