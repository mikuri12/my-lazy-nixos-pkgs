{
  lib,
  appimageTools,
  fetchurl,
}:
let
  version = "0.1.1";
  pname = "eden";

  src = fetchurl {
    url = "https://git.eden-emu.dev/eden-emu/eden/releases/download/v${version}/Eden-Linux-v${version}-amd64-gcc-standard.AppImage";
    hash = "sha256-B3iU8SmwI44hUmbfFuSKQWriemulIXoRJF0atBfioeg=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/eden.desktop \
      $out/share/applications/eden.desktop

    substituteInPlace $out/share/applications/eden.desktop \
      --replace-fail "Exec=eden" "Exec=${pname}"

    if [ -f ${appimageContents}/eden.svg ]; then
      install -Dm444 ${appimageContents}/eden.svg \
        $out/share/icons/hicolor/scalable/apps/eden.svg
    elif [ -f ${appimageContents}/eden.png ]; then
      install -Dm444 ${appimageContents}/eden.png \
        $out/share/icons/hicolor/256x256/apps/eden.png
    fi
  '';

  meta = {
    description = "Nintendo Switch emulator forked from yuzu";
    homepage = "https://eden-emu.dev";
    license = lib.licenses.gpl3Plus;
    mainProgram = "eden";
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
}
