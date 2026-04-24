{ lib
, appimageTools
, fetchurl
}:

let
  version = "6.4.59";
  src = fetchurl {
    url  = "https://api.hayase.watch/files/linux-hayase-${version}-linux.AppImage";
    hash = "sha256-wrlgFbZvCZ4sRWwA8lilMKaQPG2zAOK36PWGEDhpMPQ=";
  };
in
appimageTools.wrapType2 {
  pname   = "hayase";
  inherit version src;

  meta = with lib; {
    description = "Torrent streaming client for anime";
    homepage    = "https://hayase.watch";
    license     = licenses.gpl3Only;
    platforms   = [ "x86_64-linux" ];
    mainProgram = "hayase";
  };
}
