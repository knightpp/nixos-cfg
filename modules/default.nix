{...}: {
  imports = [
    ./nixos
    ./desktop-environment
    ./sops
    ./workarounds
    ./repl
    ./nix-serve.nix
    ./zsa-udev-rules.nix
    ./nixpkgs-unstable.nix
    ./nixbuild.nix
    ./overlay.nix
    ./nixpath.nix
    ./local-nas.nix
    ./nix-settings.nix
    ./nextcloud.nix
    ./cloudflared.nix
    ./transmission.nix
    ./readeck.nix
  ];
}
