pkgs:
builtins.attrValues {
  inherit
    (pkgs)
    du-dust
    tokei
    alejandra
    nil
    nix-init
    ;

  inherit
    (pkgs.fishPlugins) # install fish plugins system wide
    fzf-fish
    autopair
    done
    ;
}
