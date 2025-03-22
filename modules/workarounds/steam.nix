{
  lib,
  config,
  ...
}:
let
  cfg = config.workarounds.steam;
in
{
  options = {
    workarounds.steam = {
      enable = lib.mkEnableOption "steam workaround";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.sessionVariables = {
      STEAM_FORCE_DESKTOPUI_SCALING = "2";
    };
  };
}
