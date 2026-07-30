{
  config,
  inventory,
  self_name,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    mkIf
    mkEnableOption
    mkDefault
    ;
  inv = inventory.${self_name};
  net = inv.interfaces;
  cfg = config.wilkuu.firewall;

  portRangeType = types.addCheck (types.submodule {
    options = {
      from = mkOption {
        type = types.port;
        example = 100;
        description = "lowest part of the range (inclusive)";
      };
      to = mkOption {
        type = types.port;
        example = 200;
        description = "highest part of the range (inclusive)";
      };
    };
  }) (range: range.from < range.to);

  mkPortsOption =
    protocol:
    mkOption {
      type = types.listOf types.port;
      default = [ ];
      example = [ 1234 ];
      description = "List of ${protocol} ports to accept";
    };

  mkPortRangesOption =
    protocol:
    mkOption {
      type = types.listOf portRangeType;
      default = [ ];
      example = [ 1234 ];
      description = "List of ${protocol} port ranges to accept";
    };

  layerAssertions = lib.mapAttrsToList (
    layerName: layerConfig:
    let
      missing = builtins.filter (importLayer: !(cfg.layers ? ${importLayer})) layerConfig.import-layer;
    in
    {
      assertion = missing == [ ];
      message = "Layer ${layerName} imports undefined layer(s): ${toString missing}";
    }
  ) cfg.layers;
in
{
  options.wilkuu.firewall = {
    enable = mkEnableOption "firewall module";
    defaultLayer = lib.mkOption {
      type = types.str;
      default = "external";
      example = "eth";
    };
    layers = mkOption {
      default = { };
      description = "Layers and which ports should be open";
      type = types.attrsOf (
        types.submodule {
          options = {
            import-layer = mkOption {
              type = types.listOf types.str;
              default = [ ];
              example = [ "external" ];
              description = "Layer names which ports will also be opened on this layer";
            };
            allowedTCPPorts = mkPortsOption "TCP";
            allowedUDPPorts = mkPortsOption "UDP";
            allowedTCPPortRanges = mkPortRangesOption "TCP";
            allowedUDPPortRanges = mkPortRangesOption "UDP";
          };
        }
      );
    };
  };

  config = mkIf cfg.enable {
    assertions = layerAssertions;
    networking.nftables.enable = true;
    networking.firewall =
      let
        # TODO: reconsider doing this as this will only do a flat-import anything more complex would require building an import tree.
        resolvedLayers = lib.mapAttrs (
          _: l1:
          lib.foldl' (acc: set2: {
            allowedTCPPorts = acc.allowedTCPPorts ++ set2.allowedTCPPorts;
            allowedUDPPorts = acc.allowedUDPPorts ++ set2.allowedUDPPorts;
            allowedTCPPortRanges = acc.allowedTCPPortRanges ++ set2.allowedTCPPortRanges;
            allowedUDPPortRanges = acc.allowedUDPPortRanges ++ set2.allowedUDPPortRanges;
          }) l1 (map (lk: cfg.layers.${lk}) l1.import-layer)
        ) cfg.layers;

        interfaces = lib.mapAttrs (_n: interface: {
          inherit (resolvedLayers.${interface.layer})
            allowedTCPPorts
            allowedUDPPorts
            allowedTCPPortRanges
            allowedUDPPortRanges
            ;
        }) (lib.filterAttrs (_n: interface: !(builtins.elem interface.type [ "roaming" ])) net);

      in
      {
        enable = true;
        checkReversePath = mkDefault false;
        inherit interfaces;
        inherit (resolvedLayers.${cfg.defaultLayer})
          allowedTCPPorts
          allowedUDPPorts
          allowedTCPPortRanges
          allowedUDPPortRanges
          ;
      };
  };
}
