{
  appimageTools,
  fetchurl,
  makeDesktopItem,
  buildEnv,
}: let
  version = "2.7.4";
  ts = "202404050928";
  prusaslicer = appimageTools.wrapType2 {
    name = "prusaslicer";
    src = fetchurl {
      url = "https://github.com/prusa3d/PrusaSlicer/releases/download/version_${version}/PrusaSlicer-${version}+linux-x64-GTK3-${ts}.AppImage";
      hash = "sha256-t6ZahjacqLyT9ZzFUyB/XNJLod2rc6Rb2jNSI0apWoQ=";
    };
  };

  prusaslicerDesktopItem = let
    icon = fetchurl {
      url = "https://raw.githubusercontent.com/prusa3d/PrusaSlicer/master/resources/icons/PrusaSlicer.svg";
      hash = "sha256-gK6DT+AgBO1nrrqSE0p15CpRFyXTALdeFQdGFhZGpFg=";
    };
  in
    makeDesktopItem {
      name = "PrusaSlicer";
      desktopName = "PrusaSlicer";
      exec = "${prusaslicer}/bin/prusaslicer";
      terminal = false;
      mimeTypes = [
        "model/stl"
        "text/x.gcode"
        "model/3mf"
        "application/vnd.ms-3mfdocument"
        "application/prs.wavefront-obj"
        "application/x-amf"
      ];
      categories = [
        "Graphics"
        "3DGraphics"
        "Engineering"
      ];
      inherit icon;
    };
in
  buildEnv {
    name = "prusaslicer";
    paths = [prusaslicerDesktopItem prusaslicer];
  }
