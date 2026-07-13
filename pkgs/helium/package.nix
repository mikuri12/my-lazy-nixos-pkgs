{
  lib,
  appimageTools,
  fetchurl,
}: let
  pname = "helium";
  version = "0.14.5.1";
  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    hash = "sha256-JM4Tm4Le9Xcfq3fFMEu/DIK6817FEgBQ2rSwY093F04=";
  };

  appimageContents = appimageTools.extractType2 {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = import ../../lib/appimage-extras.nix {
      inherit pname;
      contents = appimageContents;
    };

    extraPkgs = pkgs: with pkgs; [libGL vulkan-loader];

    meta = {
      description = "Private, fast, and honest web browser based on Chromium";
      homepage = "https://helium.computer";
      mainProgram = "helium";
      platforms = ["x86_64-linux"];
      license = lib.licenses.unfree;
    };
  }
