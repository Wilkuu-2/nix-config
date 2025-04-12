{ pkgs, config, ...}:
{
  programs.neovim = {
    enable = true; 
     defaultEditor = true;
     viAlias = true; 
     vimAlias = true; 
     vimdiffAlias = true;
     withPython3 = true; 
     withNodeJs = true; 
     withRuby = true; 
  
     coc.enable = false; 
  # 
     plugins = [
     ];
  };

  home.file."./.config/nvim/lua/wilkuu/init.lua".text = ''
    require("wilkuu.set")
    require("wilkuu.remap")
  '';

  home.file."./.config/nvim/lua/wilkuu/nix.lua".text = ''
    return {
      vue_ts_plugin = "/home/wilkuu/.npm/@vue/typescript-plugin",
    } 
  '';

  home.sessionPath = [
    "/home/wilkuu/.npm/bin/"
  ]; 

  home.packages = with pkgs; [
    lua
    lua-language-server
    gopls 
    go
    typescript
    nodejs_22 
    rustup
    nixd 
    nixfmt-rfc-style 
    pyright
    nodePackages.intelephense
    texlive.combined.scheme-full
    texlab
  ];

}
