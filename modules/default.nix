{...}: {
  imports = [
    ./boot
    ./fileSystems
    ./networking
    ./desktop-environment
    ./sops
    ./nixpkgs-unstable
    ./workarounds
    ./repl
  ];
}
