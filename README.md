# My NixOS configuration on ZFS

Bootstraped from this template repo <https://github.com/ne9z/dotfiles-flake>.

## QOL

### Show changes between generations

```shell
nix store diff-closures /nix/var/nix/profiles/system-{1,2}-link/
```

## Debugging

```shell
nix repl
#nix-repl> :lf .
#nix-repl> nixosConfigurations.<host>.config.services ...
```
