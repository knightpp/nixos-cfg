{
  inputs,
  lib,
  pkgs,
  ...
}: let
  optType = lib.mkOptionType {
    name = "nixpkgs";
    description = "An evaluation of Nixpkgs; the top level attribute set of packages";
    check = builtins.isAttrs;
  };
in {
  options.pkgs.unstable = lib.mkOption {type = optType;};

  config.pkgs.unstable = lib.mkDefault (import inputs.unstable {
    config = {allowUnfree = true;};
    inherit (pkgs) system;
  });
}
