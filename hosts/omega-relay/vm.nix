{lib, config,...}: let 
  tcpFromHost = gport: hport: {
    from = "host"; 
    proto = "tcp"; 
    host = { 
      port = hport; 
      address = "10.0.69.1";
    };
    guest = { 
      port = gport; 
      address = "10.0.69.2";
    };
  };
in {
  virtualisation.vmVariant = {
    addons.virtualisation.isTestVM = true; 
    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=2G"
        "mode=755"
      ];
    };
   virtualization = {
      forwardPorts = [
        (tcpFromHost 80 8080)
        (tcpFromHost 22 8022)
      ]; 
      virtualisation = {
        memorySize = 2048; # Use 2048MiB memory.
        cores = 3;
        graphics = true;
      };
    };
  }; 
}
