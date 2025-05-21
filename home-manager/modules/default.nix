{lib, ...}:
with lib;
{
  imports = [
    ./apps
    ./services
    ./direnv.nix
  ]; 
}
