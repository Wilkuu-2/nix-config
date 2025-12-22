{
  config,
  inputs,
  ...
}:
{
  # Pass host config to HM (Common config)
  # TODO: Move this somewhere else.
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "bak";

    sharedModules = [
      (
        { ... }:
        {
          _module.args.hostconfig = config;
          _module.args.inputs = inputs;
        }
      )
      inputs.sops-nix.homeManagerModules.sops
    ];
  };
}
