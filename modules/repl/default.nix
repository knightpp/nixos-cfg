{
  inputs,
  pkgs,
  ...
}: {
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
  environment.systemPackages = let
    repl_path = toString ./.;
    systemRepl = pkgs.writeShellScriptBin "repl" ''
      source /etc/set-environment
      nix repl --file "${repl_path}/repl.nix" "$@"
    '';
  in [
    systemRepl
  ];
}
