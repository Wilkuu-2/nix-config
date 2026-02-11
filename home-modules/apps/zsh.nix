{
  config,
  pkgs,
  lib,
  hostconfig,
  ...
}:
{
  options.homeapps.zsh = {
    enable = lib.mkEnableOption "Enable ZSH shell";
  };

  config = lib.mkIf config.homeapps.zsh.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true; 
      autosuggestion.enable =true;
      oh-my-zsh = {
        enable = true;
        theme = "dst";
        plugins = [
          "kitty"
          "rust" 
          "screen" 
          "systemd" 
          "tmux" 
          "nmap" 
          "npm"
          "ssh" 
        ];
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
  };
}
