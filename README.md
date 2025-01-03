# My NixOS configuration on ZFS

Bootstraped from this template repo <https://github.com/ne9z/dotfiles-flake>.

## QOL

### Show changes between generations

- ∅ - empty set (removed or installed)
- ε - epsilon (no version provided)

```shell
nix store diff-closures /nix/var/nix/profiles/system-{1,2}-link/
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
