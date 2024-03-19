{
  appimageTools,
  fetchurl,
}: let
  version = "2.5.59.8";
in
  appimageTools.wrapType2 {
    name = "superslicer";
    src = fetchurl {
      url = "https://github.com/supermerill/SuperSlicer/releases/download/${version}/SuperSlicer-ubuntu_18.04-${version}.AppImage";
      hash = "sha256-EEHvdwdSXLvntIZsUfelskA6ywpifO/gVBriu78H3G8=";
    };
  }
