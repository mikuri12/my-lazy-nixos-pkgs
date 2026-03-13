{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "helium";
  version = "0.10.2.1";
  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    hash = "sha256-Kh6UgdleK+L+G4LNiQL2DkQIwS43cyzX+Jo6K0/fX1M=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };

in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/helium.png \
      $out/share/icons/hicolor/256x256/apps/helium.png 2>/dev/null || true
    install -Dm644 ${appimageContents}/helium.desktop \
      $out/share/applications/helium.desktop 2>/dev/null || true
    substituteInPlace $out/share/applications/helium.desktop \
      --replace-fail 'Exec=helium' 'Exec=helium' 2>/dev/null || true
  '';

  extraPkgs = pkgs: with pkgs; [
    libGL
    mesa
    vulkan-loader
  ];

  meta = {
    description = "Private, fast, and honest web browser based on Chromium";
    homepage = "https://helium.computer";
    mainProgram = "helium";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree;
  };
}
