{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.modules.nixpkgs-unstable;
  optType = lib.mkOptionType {
    name = "nixpkgs";
    description = "An evaluation of Nixpkgs; the top level attribute set of packages";
    check = builtins.isAttrs;
  };
in {
  options = {
    modules.nixpkgs-unstable = {
      enable = lib.mkEnableOption "Nixpkgs unstable";
      pkgs = lib.mkOption {type = optType;};
    };
  };

  config = lib.mkIf cfg.enable {
    modules.nixpkgs-unstable.pkgs = lib.mkDefault (import inputs.nixpkgs-unstable {
      config = {allowUnfree = true;};
      inherit (pkgs) system;
    });
  };
}
