{ pkgs, config, ...}:
let 
  treesitterWithGrammars = (pkgs.vimPlugins.nvim-treesitter.withPlugins (p : [
    p.bash 
    p.comment
    p.css 
    p.dockerfile
    p.gitattributes 
    p.gitignore
    p.go
    p.gomod
    p.gowork
    p.rust 
    p.javascript 
    p.typescript
    p.json5
    p.json
    p.lua
    p.markdown
    p.nix
    p.python 
    p.java 
    p.rust
    p.toml 
    p.vue 
    p.yaml
    p.php
    p.latex 
  ]));
  treesitter-parsers = pkgs.symlinkJoin {
    name = "treesitter-parsers";
    paths = treesitterWithGrammars.dependencies;
  };

in 
{
  programs.neovim = {
    enable = true; 
     defaultEditor = true;
     viAlias = true; 
     vimAlias = true; 
  #   vimdiffAlias = true;
  #   # withPython3 = false; 
  #   # withNodeJs = false; 
  #   # withRuby = false; 
  #
     coc.enable = false; 
  # 
     plugins = [
      treesitterWithGrammars
     ];
  };

  home.file."./.config/nvim/lua/wilkuu/init.lua".text = ''
    require("wilkuu.set")
    require("wilkuu.remap")
  '';
  #vim.opt.runtimepath:append("${treesitter-parsers}")

  home.file."./.config/nvim/lua/wilkuu/nix.lua".text = ''
    return {
      vue_ts_plugin = "/home/wilkuu/.npm/@vue/typescript-plugin",
    } 
  '';


  # home.file."./.local/share/nvim/nix/nvim-treesitter/" = {
  #   source = treesitterWithGrammars; 
  #   recursive = true; 
  # };

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
