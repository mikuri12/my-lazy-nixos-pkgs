{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  appimage-run,
}:
stdenv.mkDerivation rec {
  pname = "eden";
  version = "0.1.1";

  src = fetchurl {
    url = "https://git.eden-emu.dev/eden-emu/eden/releases/download/v${version}/Eden-Linux-v${version}-amd64-gcc-standard.AppImage";
    hash = "sha256-B3iU8SmwI44hUmbfFuSKQWriemulIXoRJF0atBfioeg=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp $src $out/bin/eden.AppImage
    chmod +x $out/bin/eden.AppImage

    makeWrapper ${lib.getExe appimage-run} $out/bin/eden \
      --add-flags "$out/bin/eden.AppImage"

    runHook postInstall
  '';

  meta = {
    description = "Nintendo Switch emulator forked from yuzu";
    homepage = "https://eden-emu.dev";
    license = lib.licenses.gpl3Plus;
    mainProgram = "eden";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
