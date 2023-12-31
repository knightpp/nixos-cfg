{
  fetchurl,
  writeScriptBin,
  bash,
  makeDesktopItem,
  buildEnv,
  prusa-slicer,
}: let
  prusaslicerFixed = writeScriptBin "prusa-slicer" ''
    #! ${bash}/bin/bash
    export LANGUAGE="en_US"
    export LOCALE="en_US.UTF-8"
    export LANG=""
    exec "${prusa-slicer}/bin/prusa-slicer" "$@"
  '';

  prusaslicerDesktopItem = let
    icon = fetchurl {
      url = "https://raw.githubusercontent.com/prusa3d/PrusaSlicer/master/resources/icons/PrusaSlicer.svg";
      hash = "sha256-gK6DT+AgBO1nrrqSE0p15CpRFyXTALdeFQdGFhZGpFg=";
    };
  in
    makeDesktopItem {
      name = "prusa-slicer";
      desktopName = "Prusa slicer";
      exec = "${prusaslicerFixed}/bin/prusa-slicer";
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
    name = "prusa-slicer";
    paths = [prusaslicerDesktopItem prusaslicerFixed];
  }
