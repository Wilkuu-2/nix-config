{pkgs, lib, config,...}: {
   imports = [./user-common.nix];
   programs.zsh.enable = true;
   users.users.wilkuu = {
     shell = pkgs.zsh; 
     isNormalUser = true;
     initialPassword = "PleazeChangeThis123"; 
     extraGroups = [ "wheel" "networkmanager" "input" "docker" "adbusers" "libvirtd" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       home-manager
     ];
   };

   home-manager.users.wilkuu.imports = [ ../home/wilkuu.nix ]; 

}
