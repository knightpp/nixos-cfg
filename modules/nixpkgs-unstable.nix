{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.custom.nixpkgs-unstable;
  optType = lib.mkOptionType {
    name = "nixpkgs";
    description = "An evaluation of Nixpkgs; the top level attribute set of packages";
    check = builtins.isAttrs;
  };
in {
  options = {
    custom.nixpkgs-unstable = {
      enable = lib.mkEnableOption "Nixpkgs unstable";
      pkgs = lib.mkOption {type = optType;};
    };
  };

  config = lib.mkIf cfg.enable {
    custom.nixpkgs-unstable.pkgs = lib.mkDefault (import inputs.unstable {
      config = {allowUnfree = true;};
      inherit (pkgs) system;
    });
  };
}
