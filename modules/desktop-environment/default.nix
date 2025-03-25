{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.desktop-environment;
in
{
  imports = [
    ./kde
    ./gnome
    ./hyprland
  ];

  options.desktop-environment = {
    enable = lib.mkEnableOption "Desktop Environment";
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        programs = {
          mpv = {
            enable = true;
            config = {
              ao = "pipewire";
              vo = "gpu";
              profile = "gpu-hq";
              hwdec = "auto";

              msg-color = "yes"; # color log messages on terminal
              cache = "yes"; # uses a large seekable RAM cache even for local input.
              # cache-secs=300 # uses extra large RAM cache (needs cache=yes to make it useful).
              demuxer-max-back-bytes = "20M"; # sets fast seeking
              demuxer-max-bytes = "80M"; # sets fast seeking
            };
          };
        };
      }
    ];

    networking.networkmanager.enable = true;

    xdg.portal.xdgOpenUsePortal = true;

    programs.dconf.enable = true; # Needed for easyeffects

    environment.systemPackages = builtins.attrValues {
      # superslicer = pkgs.callPackage ./../../pkgs/superslicer.nix {};
      # prusaslicer = pkgs.callPackage ./../../pkgs/prusa-slicer.nix {};
      # zenbrowser = pkgs.callPackage ./../../pkgs/zen-browser.nix {};
      heroic = pkgs.heroic.override {
        extraPkgs = pkgs: [
          pkgs.gamescope
          pkgs.mangohud
        ];
      };

      inherit (pkgs)
        appimage-run
        firefox
        vivaldi
        discord
        calibre
        handbrake
        xclip
        easyeffects
        workrave
        gparted
        rawtherapee
        signal-desktop
        rquickshare
        ghostty
        ;
    };

    # this was removed in https://github.com/NixOS/nixpkgs/pull/337345
    # hardware.alsa.enablePersistence = true; # enables alsamixer settings to be persisted across reboots

    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      # alsa.support32Bit = false; # steam sets this to true
      pulse.enable = true;
      jack.enable = true;
    };

    fonts = {
      packages = builtins.attrValues {
        inherit (pkgs)
          noto-fonts
          noto-fonts-emoji
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          dejavu_fonts
          monaspace
          ;
        nerdfonts = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
      };

      enableDefaultPackages = false; # Fixes wrong braille symbols for graph in the bottom app
      fontconfig.allowBitmaps = false;
    };
  };
}
