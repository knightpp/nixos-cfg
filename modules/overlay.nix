{
  config,
  lib,
  ...
}: let
  pkgsUnstable = config.modules.nixpkgs-unstable.pkgs;
in {
  config = lib.mkIf config.modules.nixpkgs-unstable.enable {
    nixpkgs.overlays = [
      (final: prev: {
        helix = pkgsUnstable.helix;
        ghostty = pkgsUnstable.ghostty;
        jujutsu = pkgsUnstable.jujutsu;
      })
    ];
  };
}
