{lib, pkgs, ...}: 
with lib;
{


  home.packages = with pkgs; [
    mako
    wofi
    hyprshot
    networkmanagerapplet
    xdg-desktop-portal-gnome 
    xdg-desktop-portal-hyprland
    wl-clipboard
  ];


  # Environment variables for hyprland.
  # This can be used to configure wayland/hyprland-specific things
  home.file.".config/uwsm/env-hyprland".text = ''
     export XDG_SESSION_TYPE=wayland
     export GDK_BACKEND=wayland
     export GTK_USE_PORTAL=1
     export QT_QPA_PLATFORM=wayland;xcb
     export QT_STYLE_OVERRIDE=kvantum
     export QT_QPA_PLATFORM_THEME=kvantum
     export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
     export QT_AUTO_SCREEN_SCALE_FACTOR=1
     export MOZ_ENABLE_WAYLAND=1
     export -n GTK_IM_MODULE
  '';

  # Hyprland 
  wayland.windowManager.hyprland = {
      systemd.enable = false;
      enable = true;
      xwayland.enable = true;
      settings = {
        exec-once = map (s: "uwsm app -- " + s) [
             "kitty &"
             "lxqt-policykit-agent &"
             "waybar &"
             "nm-applet &"
						 "blueman-tray &"
						 "blueman-applet &"
             "hyprctl setcursor Catppuccin-Mocha-Dark-Cursors 24"
             "kdeconnect-indicator &"
        ] ++ [
          "systemctl --user start hypridle.service"
          "systemctl --user start hyprpaper.service"
          "systemctl --user start hyprpolkitagent.service"
          "uwsm finalize QT_QPA_PLATFORM QT_PLUGIN_PATH"
          ];
        general = {
          gaps_in = 3;
          gaps_out = 8;
          border_size = 1;

          "col.active_border" = "rgba(ed45b8ee) rgba(611449ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";

          resize_on_border = true;
          allow_tearing = true;
          layout = "dwindle";
        }; 

        animations = {
          enabled = true; 
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ]; 
        }; 
         
        decoration = {
          rounding = 10;

          # Change transparency of focused and unfocused windows
          active_opacity = "1.0";
          inactive_opacity = "1.0";

          # drop_shadow = true;
          # shadow_range = 4;
          # shadow_render_power = 3;
          # "col.shadow" = "rgba(1a1a1aee)";

          # https://wiki.hyprland.org/Configuring/Variables/#blur
          blur = {
              enabled = true;
              size = 3;
              passes = 1;
              
              vibrancy = "0.1696";
          };
        };    
        dwindle = {
          pseudotile = true; 
          preserve_split = true;
        }; 

        #master = {
          # new_is_master = true;
        #};
        input = {
            kb_layout = "pl";
            kb_variant = "";
            kb_model = "";
            kb_options = "";
            kb_rules = ""; 

            follow_mouse = 1;

            sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

            touchpad = {
                natural_scroll = true;
            };
        };
        gestures =  {
            workspace_swipe = true; 
        }; 
        misc = { 
          force_default_wallpaper = "-1"; # Set to 0 or 1 to disable the anime mascot wallpapers
          disable_hyprland_logo = false; # If true disables the random hyprland logo / anime girl background. :(
        };
        monitor= [ ",preferred,auto,1" ];
        
        # Mod key
        "$mod" = "SUPER";
        
        # Programs 
        "$terminal" = "kitty";
        "$fileManager" = "thunar";
        "$menu" = "wofi --show drun";
        "$screenshot" = "hyprshot -m region -f screenshots/screenshot_$(date +'%d-%m-%y_%H-%M-%S').png";
        

        bind = [
             # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
             "$mod, RETURN, exec, $terminal"
             "$mod, Q, killactive,"
             "$mod SHIFT, M, exec, uwsm stop"
             "$mod, E, exec, uwsm app -- $fileManager"
             "$mod, V, togglefloating,"
             "$mod, R, exec, uwsm app -- $menu"
             "$mod, P, pseudo"
             "$mod, J, togglesplit"
             "$mod, L, exec, uwsm app -- hyprlock"
             ",Print, exec, uwsm app -- $screenshot  "

             # Move focus with mod + arrow keys
             "$mod, left, movefocus, l"
             "$mod, right, movefocus, r"
             "$mod, up, movefocus, u"
             "$mod, down, movefocus, d"

             # Example special workspace (scratchpad)
             "$mod, S, togglespecialworkspace, magic"
             "$mod SHIFT, S, movetoworkspace, special:magic"

             # Scroll through existing workspaces with mod + scroll
             "$mod, mouse_down, workspace, e+1"
             "$mod, mouse_up, workspace, e-1"
            ]  ++ (
        # workspaces
        builtins.concatLists (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in [
              # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
             
              # Move workspace {1..10} to current monitor
              "CTRL ALT $mod , ${ws}, focusworkspaceoncurrentmonitor, ${toString(x + 1)}"
            ]
          )
          10)
      ) ++ (
      # Monitor {0..4} --> Key {1..5}
      builtins.concatLists (builtins.genList (
        x: let 
          mon = builtins.toString(x); 
          key = builtins.toString(x + 1);
          in [
      
              # Move current workspace to a monitor {1..4}
              "CTRL ALT SHIFT $mod, ${key}, movecurrentworkspacetomonitor, ${mon} "
          ]
      )
      4));

        bindm = [
           "$mod, mouse:272, movewindow"
           "$mod, mouse:273, resizewindow"
        ]; 
        

        windowrulev2 = [
             "suppressevent maximize, class:.*" # You'll probably like this.
        ];

        source = [
            "~/.config/hypr/hypr_test.conf"
        ];
      }; 
  }; 

  services.hyprpaper = {
    enable = true; 
    settings = {
      ipc = "on";
      splash = false;
      splash_offset = 2.0;

      preload =
        [ "/home/wilkuu/Pictures/Wallpapers/peony.png" ];
      wallpaper= [",/home/wilkuu/Pictures/Wallpapers/peony.png"];
      };
  }; 

  programs.hyprlock = {
    enable=true; 
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 0;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 16;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "<span foreground=\"##cad3f5\">Password...</span>";
          shadow_passes = 2;
        }
      ];
    };
  };

  services.hypridle.enable = true; 
  services.hypridle.settings = {
    general = {
      lock_cmd ="pidof hyprlock || hyprlock"; 
      before_sleep_cmd="loginctl lock-session";
      ignore_dbus_inhibit=false; 
      after_sleep_cmd="hyprctl_dispatch dpms on";
    };
    listener = [
      {
        timeout = 30;
        on-timeout = "hyprlock"; 
      } 
      {
        timeout = 90;
        on-timeout = "hyprctl dispatch dpms off";
        on-resume = "hyprctl dispatch dpms on";      
      }
    ];
  };

}
