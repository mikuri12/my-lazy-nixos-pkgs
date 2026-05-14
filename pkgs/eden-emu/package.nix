{
  lib,
  appimageTools,
  fetchurl,
}:
appimageTools.wrapType1 {
  pname = "eden";
  version = "0.1.1";

  src = fetchurl {
    url = "https://git.eden-emu.dev/eden-emu/eden/releases/download/v0.1.1/Eden-Linux-v0.1.1-amd64-gcc-standard.AppImage";
    hash = "sha256-B3iU8SmwI44hUmbfFuSKQWriemulIXoRJF0atBfioeg=";
  };

  meta = {
    description = "Nintendo Switch emulator forked from yuzu";
    homepage = "https://eden-emu.dev";
    license = lib.licenses.gpl3Plus;
    mainProgram = "eden";
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
}
