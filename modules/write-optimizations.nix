{
  config,
  lib,
  ...
}: let
  cfg = config.modules.write-optimizations;
in {
  options.modules.write-optimizations = {
    enable = lib.mkEnableOption "write optimizations";
  };

  config = lib.mkIf cfg.enable {
    services.journald.extraConfig = ''
      Storage=volatile
      RuntimeMaxUse=64M
    '';

    boot = {
      tmp.useTmpfs = true;
      kernel.sysctl = {
        "vm.swappiness" = 5;
        "vm.dirty_background_ratio" = 50;
        "vm.dirty_ratio" = 50;
        "vm.dirty_expire_centisecs" = 120 * 100;
      };
    };
  };
}
