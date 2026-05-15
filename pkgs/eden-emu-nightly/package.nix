{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "eden-nightly";
  version = "7e84f9ef59";

  src = fetchurl {
    url = "https://nightly.eden-emu.dev/v1778614183.${version}/Eden-Linux-${version}-amd64-clang-pgo.AppImage";
    hash = "sha256-WPPxXMuzhYx1Ira4i/9kE6c7nQcZvJRRhUahDXQK/3w=";
  };

  dontUnpack = true;
  dontBuild = true;
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp $src $out/bin/eden-nightly
    chmod +x $out/bin/eden-nightly
    runHook postInstall
  '';

  meta = {
    description = "Nintendo Switch emulator forked from yuzu (nightly PGO build)";
    homepage = "https://eden-emu.dev";
    license = lib.licenses.gpl3Plus;
    mainProgram = "eden-nightly";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
