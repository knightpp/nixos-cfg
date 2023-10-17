{...}: {
  imports = [
    ./zfs
    ./desktop-environment
    ./sops
    ./nixpkgs-unstable
    ./workarounds
    ./repl
    ./nix-serve.nix
  ];
}
