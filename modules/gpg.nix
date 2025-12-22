{
  config,
  lib,
  ...
}:
let
  cfg = config.addons.gpg;
in
{
  options.addons.gpg = {
    enable = lib.mkEnableOption "Allow gpg for all users";
  };

  config = lib.mkMerge ([
    (lib.mkIf cfg.enable {
      programs.gnupg = {
        agent = {
          enable = true;
        };
      };
    })
  ]);

}
