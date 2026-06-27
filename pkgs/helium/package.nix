{
  lib,
  appimageTools,
  fetchurl,
}: let
  pname = "helium";
  version = "0.10.2.1";
  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    hash = "sha256-Kh6UgdleK+L+G4LNiQL2DkQIwS43cyzX+Jo6K0/fX1M=";
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
