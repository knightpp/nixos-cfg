{
  config,
  lib,
  ...
}: let
  pkgsUnstable = config.custom.nixpkgs-unstable.pkgs;
in {
  config = lib.mkIf config.custom.nixpkgs-unstable.enable {
    nixpkgs.overlays = [
      (final: prev: {
        helix = pkgsUnstable.helix;
        ghostty = pkgsUnstable.ghostty;
        jujutsu = pkgsUnstable.jujutsu;
      })
    ];
  };
}
