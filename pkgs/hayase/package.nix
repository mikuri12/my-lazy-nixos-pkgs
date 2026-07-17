{
  lib,
  appimageTools,
  fetchurl,
}: let
  pname = "hayase";
  version = "6.4.83";
  src = fetchurl {
    url = "https://api.hayase.watch/files/linux-hayase-${version}-linux.AppImage";
    hash = "sha256-7m0Fdi8lEEfPGimijBbNW4wCzdeomEh+nXtJ173S/mg=";
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
