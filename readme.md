# My NixOS configurations

## QOL

### Show changes between generations

- ∅ - empty set (removed or installed)
- ε - epsilon (no version provided)

```shell
nix store diff-closures /nix/var/nix/profiles/system-{1,2}-link/
```

### CLI

Quickly build a package

```nix
nix eval --impure --expr '(import <nixpkgs> {}).callPackage ./package.nix {}'
```

## Debugging

```shell
nix repl
#nix-repl> :lf .
#nix-repl> nixosConfigurations.<host>.config.services ...
```

## Sops

### Generate age key from SSH

```shell
mkdir -p ~/.config/sops/age/
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/personal >> ~/.config/sops/age/keys.txt"
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key >> ~/.config/sops/age/keys.txt"
```

### Age private key to public

```shell
age-keygen -y ~/.config/sops/age/keys.txt
```

### Edit encrypted file

```shell
sops ./secrets/secrets.yaml
```

### When token expires

```fish
# export NIX_CONFIG=... # in bash
set -x NIX_CONFIG 'access-tokens = github.com=working_access_token'
# now nix commands won't fail
```

## Maintenance

### Clean up space

It's important to run `nix-collect-garbage` as user to remove stale data in `~/.local/state/home-manager/`.

```shell
nix-collect-garbage -d
doas nix-collect-garbage -d
```
