#!/bin/sh 
set -x


#  sudo bash -c "nixos-rebuild switch --flake /home/wilkuu/nix-config#apocalypse --log-format internal-json -v |& nom --json" 
dir=$(dirname "$0")
host=$1; shift; 
args=$@ 
# Check if nom is present
nom_cmd="nom --json" 
cat_cmd="cat"
output_monitor_cmd=$(which nom 2>&1 > /dev/null && echo $nom_cmd || echo $cat_cmd)


nixos-rebuild switch --flake $dir\#$host --log-format internal-json -v $args |& $output_monitor_cmd     
