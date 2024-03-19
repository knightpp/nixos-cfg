{
  appimageTools,
  fetchurl,
  makeDesktopItem,
  buildEnv,
}: let
  version = "2.5.59.8";
  superslicer = appimageTools.wrapType2 {
    name = "superslicer";
    src = fetchurl {
      url = "https://github.com/supermerill/SuperSlicer/releases/download/${version}/SuperSlicer-ubuntu_18.04-${version}.AppImage";
      hash = "sha256-EEHvdwdSXLvntIZsUfelskA6ywpifO/gVBriu78H3G8=";
    };
  };

  superslicerDesktopItem = let
    icon = fetchurl {
      url = "https://raw.githubusercontent.com/supermerill/SuperSlicer/master/resources/icons/SuperSlicer.svg";
      hash = "sha256-PhOCUe8FgmTxkqta5uka5YtrWwZl7MiIqYkAIM492X0=";
    };
  in
    makeDesktopItem {
      name = "SuperSlicer";
      desktopName = "SuperSlicer";
      exec = "${superslicer}/bin/superslicer";
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
    name = "superslicer";
    paths = [superslicerDesktopItem superslicer];
  }
