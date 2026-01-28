{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.homeprogs.mako;
in
{
  options.homeprogs.mako = {
    enable = lib.mkEnableOption "Enable Mako notification manager";
    systemdWantedBy = lib.mkOption {
      description = "SystemD targets where mako should start for.";
      # TODO: Put a null here, so that we can add a non-persistent default
      default = [ ];
      example = [ "hyprland-session.target" ];
      type = lib.types.listOf lib.types.str;
    };
    package = lib.mkOption {
      description = "mako package to use";
      default = pkgs.mako;
      example = pkgs.mako;
      type = lib.types.package;
    };
  };
  config = lib.mkIf config.homeprogs.mako.enable ({
    home.packages = [ pkgs.mako ];
    xdg.configFile."mako/config" = {
      onChange = "${pkgs.mako}/bin/makoctl reload || true";
      source = ./mako.ini;
    };
    systemd.user.services.mako = {
      Install.WantedBy = config.homeprogs.mako.systemdWantedBy;
      Unit = {
        Description = "Lightweight Wayland notification daemon";
        Documentation = "man:mako(1)";
        After = "graphical-session.target";
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        ExecCondition = "/bin/sh -c '[ -n \"$WAYLAND_DISPLAY\" ]'";
        ExecStart = "${cfg.package}/bin/mako";
        ExecReload = "${cfg.package}/bin/makoctl reload";
      };
    };
  });
}
