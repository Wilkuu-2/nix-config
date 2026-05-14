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
    home.sessionVariables = {
      EDITOR = "nvim";
    };

    programs.neovim = {
      enable = false;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withPython3 = false;
      withNodeJs = false;
      withRuby = false;

      # coc.enable = false;
    };

    home.file = lib.mkIf config.homeapps.nvim.lsp {
      "./.config/nvim/lua/wilkuu/nix.lua".text = ''
        return { 
          vue_ts_plugin = "${lib.getBin vue_ls}/lib/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin/"
        } 
      '';
    };

    home.sessionPath = [
      "/home/wilkuu/.npm/bin/"
    ];

    home.packages =
      with pkgs;
      lib.mkMerge [
        (lib.mkIf config.homeapps.nvim.lsp ([
          lua
          lua-language-server
          ts_ls
          vue_ls
        ]))
        [
          neovim
          neovim-node-client
        ]
      ];
  };
}
