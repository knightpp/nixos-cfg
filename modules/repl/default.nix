{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  cfg = config.repl;
in {
  options = {
    repl.enable = lib.mkEnableOption "repl";
  };

  config = lib.mkIf cfg.enable {
    nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
    environment.systemPackages = let
      repl_path = toString ./../../repl.nix;
      systemRepl = pkgs.writeShellScriptBin "repl" ''
        source /etc/set-environment
        nix repl --file "${repl_path}" "$@"
      '';
    in [
      systemRepl
    ];
  };
}
