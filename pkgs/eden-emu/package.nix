{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "eden";
  version = "0.1.1";

  src = fetchurl {
    url = "https://stable.eden-emu.dev/v${version}/Eden-Linux-v${version}-amd64-gcc-standard.AppImage";
    hash = "sha256-B3iU8SmwI44hUmbfFuSKQWriemulIXoRJF0atBfioeg=";
  };

  dontUnpack = true;
  dontBuild = true;
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp $src $out/bin/eden
    chmod +x $out/bin/eden
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
