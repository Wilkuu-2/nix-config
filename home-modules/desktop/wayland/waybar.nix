{pkgs, hostconfig, lib, config,...}: {
  options.homeprogs.waybar.enable = lib.mkEnableOption "Enable waybar";

  config = lib.mkIf config.homeprogs.waybar.enable {
    programs.waybar = { 
      enable = true; 
      settings = [{
        layer = "top";
        position = "top";
        height = 30; 
        spacing = 6; 
        modules-left = [
          "hyprland/workspaces" 
          "hyprland/window"
        ]; 

        modules-center = [
          "clock"
          "hyprland/language"
          "tray"
          "battery"
        ];

        modules-right = [
          "idle_inhibitor"
          "wireplumber"
          "network"
          "cpu"
          "memory"
          "disk"
          "temperature"
          "backlight"
        ];
        wireplumber = {
            scroll-step = 1; #%, can be a float
            format = "{volume}% ";
            format-muted = "Muted";
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            on-click-right =  "pavucontrol";  
        };

        network = {
            # interface = "wlp2*"; # (Optional) To force the use of this interface
            format-wifi = "({signalStrength}%) ";
            format-ethernet = "{ifname} ";
            tooltip-format = "{ifname} via {gwaddr} ";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "Disconnected ⚠";
            format-alt= "{essid}: {ipaddr}/{cidr}";
        };

       "hyprland/workspaces" = {
           all-outputs = false;
           active-only = false;
           format = "{name}";
           format-icons = {
               urgent = "";
               focused = "";
               default = "";
           };
       };
      
      "hyprland/window" = {
        max-length = 200;
        separate-outputs = true;
      };


      keyboard-state = {
          numlock = false;
          format = "{name} {icon}";
          format-icons = {
              locked = "";
              unlocked = "";
          };
      };
      idle_inhibitor = {
          format = "{icon}";
          format-icons = {
              activated = "";
              deactivated = "";
          };
      };
      tray = {
          icon-size = 21;
          spacing = 10;
      };
      clock = {
          timezone = "Europe/Amsterdam";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%Y-%m-%d}";
      };
      cpu = {
          format = "{usage}% ";
          tooltip = false;
      };
      memory = {
          format = "{}% ";
      };
      temperature = {
          thermal-zone = 1;
          # hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
          critical-threshold = 80;
          # format-critical = "{temperatureC}°C {icon}";
          format = "{temperatureC}°C {icon}";
          format-icons = ["" "" ""];
      };
      "backlight" = {
          # device = "acpi_video1";
          format = "{percent}{icon}";
          format-icons = ["" "" "" "" "" "" "" "" ""];
      };
        battery = {
            states = {
                # good = 95;
                warning = 30;
                critical = 15;
            };
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            format-alt = "{time} {icon}";
            # format-good = ""; // An empty format will hide the module
            # format-full = "";
            format-icons = ["" "" "" "" ""];
        };
      }]; 
      style = ./waybar.css;
    }; 
  };
}
