{
  lib,
  stdenvNoCC,
  appimageTools,
  fetchurl,
  dwarfs,
}: let
  pname = "eden-nightly";
  timestamp = "1782934895";
  version = "bdf60d79a0";
  hash = "sha256-DI00qcEy+25XHD4qZCmPnUO48g6Q47YWjrB2jy6jCKU=";

  src = fetchurl {
    url = "https://nightly.eden-emu.dev/v${timestamp}.${version}/Eden-Linux-${version}-amd64-clang-pgo.AppImage";
    inherit hash;
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
      aliases = ["eden"];
    };

    meta = {
      description = "Nintendo Switch emulator forked from yuzu (nightly PGO build)";
      homepage = "https://eden-emu.dev";
      license = lib.licenses.gpl3Plus;
      mainProgram = "eden-nightly";
      platforms = ["x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
