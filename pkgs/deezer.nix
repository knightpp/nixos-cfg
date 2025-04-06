{
  appimageTools,
  fetchurl,
  makeDesktopItem,
  buildEnv,
}:
let
  version = "7.0.40";
  deezer = appimageTools.wrapType2 {
    name = "deezer";
    src = fetchurl {
      url = "https://github.com/aunetx/deezer-linux/releases/download/v${version}/deezer-desktop-${version}-x86_64.AppImage";
      hash = "sha256-r0/ifkFX6gBPeqW+cz3X1Qcw8UiNQ2vSYtTM2ghi/ds=";
    };
  };

  deezerDesktopItem =
    let
      icon = fetchurl {
        url = "https://raw.githubusercontent.com/aunetx/deezer-linux/3f4767f848acee4de13a0705f8b4a7b68138db42/dev.aunetx.deezer.svg";
        hash = "sha256-ypRNKFOrTcma5bOm1tmeQK2xWDUJxd1jbkwXoxk3xUU=";
      };
    in
    makeDesktopItem {
      name = "Deezer";
      desktopName = "Deezer";
      exec = "${deezer}/bin/deezer";
      terminal = false;
      startupWMClass = "Deezer";
      mimeTypes = [
        "x-scheme-handler/deezer"
      ];
      categories = [
        "Audio"
        "Music"
        "Player"
        "AudioVideo"
      ];
      inherit icon;
    };
in
buildEnv {
  name = "deezer";
  paths = [
    deezerDesktopItem
    deezer
  ];
}
