{
  lib,
  stdenvNoCC,
  appimageTools,
  fetchurl,
  dwarfs,
}: let
  pname = "eden";
  version = "0.1.1";

  src = fetchurl {
    url = "https://stable.eden-emu.dev/v${version}/Eden-Linux-v${version}-amd64-gcc-standard.AppImage";
    hash = "sha256-B3iU8SmwI44hUmbfFuSKQWriemulIXoRJF0atBfioeg=";
  };

  extracted = stdenvNoCC.mkDerivation {
    name = "${pname}-${version}-extracted";
    inherit src;
    nativeBuildInputs = [dwarfs];
    dontUnpack = true;
    buildPhase = ''
      runHook preBuild
      mkdir -p $out
      dwarfsextract --input "$src" --image-offset auto --output "$out"
      runHook postBuild
    '';
  };
in
  appimageTools.wrapAppImage {
    inherit pname version;
    src = extracted;

    extraPkgs = pkgs: with pkgs; [libGL vulkan-loader];

    extraInstallCommands = import ../../lib/appimage-extras.nix {
      inherit pname;
      contents = extracted;
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
