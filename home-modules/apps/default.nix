{lib, pkgs, inputs, config, ...}:
with lib;
let
cfg = config.homeapps.presets;
in 
{
   imports = [
     ./nvim
     ./desktop 
     ./zsh.nix
   ];

  options.homeapps.presets = {
    base.enable = lib.mkOption { 
      type = lib.types.bool; 
      default = true; 
        description ="Enable basics for home-config";
    } ;
    full.enable = lib.mkEnableOption  "Enable everything" ;
    email.enable = lib.mkEnableOption "Enable email-related config";
    browser.enable = lib.mkEnableOption "Enable the browser (librewolf)";
    comms.enable = lib.mkEnableOption "Enable communication-related config";
    utils.enable = lib.mkEnableOption "Enable utilities" ;
    note-taking.enable = lib.mkEnableOption "Enable note taking apps"; 
    art.enable = lib.mkEnableOption "Enable art apps config"; 
    work.enable = lib.mkEnableOption "Enable research-related config"; 
    dev.enable = lib.mkEnableOption "Enable development apps"; 
    connectivity.enable = lib.mkEnableOption "Enable connectivity"; 
    multimedia.enable = lib.mkEnableOption "Enable multimedia apps"; 
    games.enable = lib.mkEnableOption "Enable games"; 
  };
  

  config = lib.mkMerge [
    (lib.mkIf cfg.full.enable {
      homeapps.presets = { 
        base.enable = true;
        email.enable = true;
        browser.enable = true;
        comms.enable = true;
        utils.enable = true;
        note-taking.enable = true;
        art.enable = true;
        work.enable = true;
        dev.enable = true;
        connectivity.enable = true;
        multimedia.enable = true;
        games.enable = true;
      };
    })
    (lib.mkIf cfg.base.enable {
      home.packages = with pkgs; [
        lm_sensors 
      ];
      homeapps.zsh.enable = true; 
      homeapps.nvim.enable = true; 
    })
    (lib.mkIf cfg.email.enable {
      home.packages = with pkgs; [
      ];
    })
    (lib.mkIf cfg.comms.enable {
      home.packages = with pkgs; [
        iamb
      ];
    })
    (lib.mkIf cfg.utils.enable {
      home.packages = with pkgs; [
        htop
        btop 
        nmap 
        dig
        ripgrep 
        unzip 
        unrar
        sshfs
        xdg-user-dirs
        zsh
        ranger
        file
      ];
    })
    (lib.mkIf cfg.note-taking.enable {
      home.packages = with pkgs; [ ];
      # Todo force synthing to be on here 
    })
    (lib.mkIf cfg.work.enable {
      home.packages = with pkgs; [
      ];
    })
    (lib.mkIf cfg.dev.enable {
      home.packages = with pkgs; [
        cmake 
        ( hiPrio gcc)
        gnumake
        clang
        rustup
        pkg-config
      ];
      homeapps.nvim.enable = true;
      homesv.direnv.enable = true;
    })
    (lib.mkIf cfg.connectivity.enable {
      home.packages = with pkgs; [
        eduvpn-client 
      ];
      services.syncthing = {
        enable = true; 
      }; 
    })
    (lib.mkIf cfg.multimedia.enable {
      home.packages = with pkgs; [
        ani-cli
        playerctl
      ];

      services.playerctld.enable = true; 
      services.spotifyd = {
        enable = true; 
        settings = {
          global = {
            device_name = "Apocalypse Nix"; 
          }; 
          discovery = {
            zeroconf_port = 5352; 
          };
          # FIXME: Add a hook for notifications
        }; 
      };
    })
    (lib.mkIf cfg.games.enable {
      home.packages = with pkgs; [
      ];
    })
  ];
}
