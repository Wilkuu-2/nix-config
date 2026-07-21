{inputs, ...}: {
  omega-relay = {
    type = "server";
    system = "x86_64-linux"; 
    nix  = true;
    nix-modules = [ 
      ./users/wilkuu-server.nix 
      inputs.stalwart-nix.nixosModules.default
    ];
    interfaces = {};
  };  
  apocalypse = {
    type = "desktop"; 
    system = "x86_64-linux"; 
    nix  = true; 
    nix-modules = [
      ./users/wilkuu.nix
    ]; 
    interfaces = {}; 
  }; 
  tacitus = {
    type = "desktop"; 
    system = "x86_64-linux"; 
    nix = true; 
    nix-modules = [
      ./users/wilkuu-server.nix 
    ]; 
    interfaces = {}; 

  };
  # TODO: Support for live images as packages
  # full-iso = {
  #   type = "live";
  #  system = "x86_64-linux"; 
  #  nix = true; 
  #  nix-paths = [
  #    ./users/live-user.nix 
  #  ]; 
  #  interfaces = null; 
  # };
}
