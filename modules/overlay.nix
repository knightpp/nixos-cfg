{
  config,
  lib,
  ...
}:
let
  unstable = config.modules.nixpkgs-unstable;
in
{
  config = lib.mkIf unstable.enable {
    nixpkgs.overlays = [
      (final: prev: {
        helix = unstable.pkgs.helix;
        ghostty = unstable.pkgs.ghostty;
        jujutsu = unstable.pkgs.jujutsu;
        readeck = unstable.pkgs.readeck;
        elixir = prev.elixir_1_18;
      })
    ];
  };
}
