{pkgs, ...}: 
{
  programs.ghidra = {
    enable = true; 
    gdb = true;
  };
} 
