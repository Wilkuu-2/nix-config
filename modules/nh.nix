{ lib, config, ... }:
let
  conf = config.addons.nh;
in
{
  options.addons.nh = {
    enable = lib.mkOption {
      default = true;
      description = "Enable nix cli helper";
    };

    flake_path = lib.mkOption {
      default = "/home/wilkuu/nix-config/";
      description = "Flake location for nh to use";
    };
  };

  config = {
    programs.nh = {
      enable = conf.enable;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = conf.flake_path; # sets NH_OS_FLAKE variable for you
    };
  };
}
