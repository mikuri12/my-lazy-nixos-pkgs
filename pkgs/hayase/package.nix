{
  lib,
  appimageTools,
  fetchurl,
}: let
  pname = "hayase";
  version = "6.4.79";
  src = fetchurl {
    url = "https://api.hayase.watch/files/linux-hayase-${version}-linux.AppImage";
    hash = "sha256-s3+t5slPz6qNZ60FDyWMR/LJSYvFI3BmZtoOUPGEZm8=";
  };

  appimageContents = appimageTools.extractType2 {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = import ../../lib/appimage-extras.nix {
      inherit pname;
      contents = appimageContents;
    };

    meta = with lib; {
      description = "Torrent streaming client for anime";
      homepage = "https://hayase.watch";
      license = licenses.gpl3Only;
      platforms = ["x86_64-linux"];
      mainProgram = "hayase";
    };
  }
