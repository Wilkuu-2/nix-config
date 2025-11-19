{
  pkgs,
  config,
  lib,
  ...
}:
let
  ts_ls = pkgs.typescript-language-server;
  vue_ls = pkgs.vue-language-server;
in
{
  options.homeapps.nvim = {
    enable = lib.mkEnableOption "Enables neovim configuration";
    lsp = lib.mkEnableOption "Enables LSP Support and the needed servers";  
  };

  config = lib.mkIf config.homeapps.nvim.enable {
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
      plugins = [
      ];
    };

    home.file."./.config/nvim/lua/wilkuu/init.lua".text = ''
      require("wilkuu.set")
      require("wilkuu.remap")
    '';

    home.file."./.config/nvim/lua/wilkuu/nix.lua".text = ''
      return { 
        vue_ts_plugin = "${lib.getBin vue_ls}/lib/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin/"
      } 
    '';

    home.sessionPath = [
      "/home/wilkuu/.npm/bin/"
    ];

    home.packages = lib.mkIf config.homeapps.nvim.lsp (
      with pkgs;
      [
        lua
        lua-language-server
        gopls
        go
        typescript
        nodejs_22
        rustup
        nil
        statix
        nixfmt-rfc-style
        # phpactor
        pyright
        nodePackages.intelephense
        texlive.combined.scheme-medium
        texlab
        mermaid-cli
        ltex-ls
        deno
      ]
      ++ [
        ts_ls
        vue_ls
      ]);
  };
}
