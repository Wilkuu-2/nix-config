{ ... }:
let
  forward = proto: gport: hport: {
    from = "host";
    proto = proto;
    host = {
      port = hport;
      # address = "10.0.69.1";
    };
    guest = {
      port = gport;
      # address = "10.0.69.2";
    };
  };
in
{
  # TODO: Make this into a more global module.
  virtualisation.vmVariant = {
    addons.virtualisation.isTestVM = true;
    addons.virtualisation.guest = true;
    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=2G"
        "mode=755"
      ];
    };
    virtualisation = {
      forwardPorts = [
        (forward "tcp" 80 9080)
        (forward "tcp" 443 9443)
        (forward "tcp" 143 9143)
        (forward "tcp" 25 9025)
        (forward "tcp" 22 9022)
      ];
      memorySize = 2048; # Use 2048MiB memory.
      cores = 3;
      graphics = false;
    };
  };
}
