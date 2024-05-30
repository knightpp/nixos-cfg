pkgs:
builtins.attrValues {
  inherit
    (pkgs)
    du-dust
    tokei
    alejandra
    nil
    nix-init
    nurl # generates nix fetcher expressions based on url
    
    # zig
    
    zig
    zls
    # GO
    
    go
    go-tools
    gopls
    delve
    gomodifytags
    # Rust
    
    rustup
    ;

  inherit
    (pkgs.fishPlugins) # install fish plugins system wide
    fzf-fish
    autopair
    done
    ;
}
