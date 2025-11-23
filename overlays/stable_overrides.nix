{nixpkgs, nixpkgs-stable, ...}:  
  (final: prev: 
  let 
    pkgs-stable = nixpkgs-stable.legacyPackages.${prev.system}; 
  in {
        
  }) 

