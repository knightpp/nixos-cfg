{...}: {
  imports = [
    ./zfs
    ./desktop-environment
    ./sops
    ./workarounds
    ./repl
    ./nix-serve.nix
    ./zsa-udev-rules.nix
    ./nixpkgs-unstable.nix
    ./nixbuild.nix
  ];
}
