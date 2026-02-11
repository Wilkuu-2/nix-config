{pkgs, config, lib, ...}:
  let 
    banner_script = pkgs.writeShellScript "motd_banner.sh" ''
      echo "This is a nice banner, property of wilkuu (wilkuu.xyz)"
      echo -e "\n\tTODO: Put a banner here\t\n"
      echo "Current hostname: ${config.networking.hostName}"
      '';
    
    # Code stolen from the nix store so I can finish motd_shell 
    motdConf =
    pkgs.runCommand "motd.toml"
      {
        __structuredAttrs = true;
        inherit (config.programs.rust-motd) order settings;
        nativeBuildInputs = [
          pkgs.remarshal
          pkgs.jq
        ];
      }
      ''
        cat "$NIX_ATTRS_JSON_FILE" \
          | jq '.settings as $settings
                | .order
                | map({ key: ., value: $settings."\(.)" })
                | from_entries' -r \
          | json2toml /dev/stdin "$out"
      '';
    
    motd_shell = pkgs.writeShellScriptBin "motd_shell" ''
      if [[ -n "$SHOW_MOTD" && -x /run/current-system/sw/bin/rust-motd ]]; then
        unset SHOW_MOTD
        ${pkgs.rust-motd}/bin/rust-motd ${motdConf}
      fi
      $1
    '';  
  in {
  environment.systemPackages = with pkgs; [
    rust-motd motd_shell
  ];
  programs.rust-motd = {
    enable = true;  
    order = [
      "banner"
      "uptime"
      "load_avg"
      "filesystems"
      "memory"
      "last_run"
      "global"
    ]; 
    settings = {
      banner = {
        color   = "light_magenta";
        # TODO: Make this nice
        command = "bash ${banner_script}";
      };
      uptime = {
        prefix = "Uptime: ";
      };  
      load_avg = {
        format = ''
        Load: [1m] [5m] [15m]
              {one:.02} , {five:.02} , {fifteen:.02}
'';
      };
      filesystems = {
        root  = "/"; 
        store = "/store2";
        ntfs  = "/win_games";
      }; 
      memory = {
        swap_pos = "beside"; 
      }; 
      last_run = {};
    };
  };
  security.pam.services.kitty = {
    showMotd = true;
  };
  security.pam.services.kitty-wrapper = {
    showMotd = true;
  };
  security.pam.services.login = {
    showMotd = true;
  };



}
