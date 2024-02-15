{
  appimageTools,
  fetchurl,
  writeScriptBin,
  bash,
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

  superslicerFixed = writeScriptBin "superslicer" ''
    #! ${bash}/bin/bash
    # AppImage version of Cura loses current working directory and treats all paths relateive to $HOME.
    # So we convert each of the files passed as argument to an absolute path.
    # This fixes use cases like `cd /path/to/my/files; cura mymodel.stl anothermodel.stl`.
    # args=()
    # for a in "$@"; do
    #   if [ -e "$a" ]; then
    #     a="$(realpath "$a")"
    #   fi
    #   args+=("$a")
    # done
    # exec "${superslicer}/bin/superslicer" "''${args[@]}"

    export LANGUAGE="en_US"
    export LOCALE="en_US.UTF-8"
    export LANG=""
    exec "${superslicer}/bin/superslicer" "$@"
  '';

  superslicerDesktopItem = let
    icon = fetchurl {
      url = "https://raw.githubusercontent.com/supermerill/SuperSlicer/master/resources/icons/SuperSlicer.svg";
      hash = "sha256-PhOCUe8FgmTxkqta5uka5YtrWwZl7MiIqYkAIM492X0=";
    };
  in
    makeDesktopItem {
      name = "SuperSlicer";
      desktopName = "SuperSlicer";
      exec = "${superslicerFixed}/bin/superslicer";
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
    paths = [superslicerDesktopItem superslicerFixed];
  }
