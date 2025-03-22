{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nix-settings;
in
{
  options.modules.nix-settings = {
    enable = lib.mkEnableOption "custom nix settings" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    nix = {
      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # connect-timeout and fallback are needed when some sibstituters become offline, so
      # we won't wait indefinitely and fail.
      # see https://jackson.dev/post/nix-reasonable-defaults/
      extraOptions = ''
        connect-timeout = 1
        log-lines = 25
        fallback = true
        auto-optimise-store = true
      '';
    };
  };
}
