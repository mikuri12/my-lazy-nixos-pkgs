{
  lib,
  appimageTools,
  fetchurl,
  webkitgtk_4_1,
  ffmpeg,
  glib-networking,
  gst_all_1,
}:

let
  pname = "spotiflac";
  version = "7.1.1";
  src = fetchurl {
    url = "https://github.com/afkarxyz/SpotiFLAC/releases/download/v${version}/SpotiFLAC.AppImage";
    hash = "sha256-X28bE3JEBvKpsDQ1uHKCFTxAa3IK2l/pK2WCq+3oMPY=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };

  runtimeLibs = [
    webkitgtk_4_1
    ffmpeg
  ];

  gstPlugins = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
  ];

in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
  install -Dm644 ${appimageContents}/spotiflac.png \
    $out/share/icons/hicolor/256x256/apps/spotiflac.png

  install -Dm644 ${appimageContents}/spotiflac.desktop \
    $out/share/applications/spotiflac.desktop

  substituteInPlace $out/share/applications/spotiflac.desktop \
    --replace-fail 'Exec=SpotiFLAC' 'Exec=spotiflac'
'';

  extraPkgs = pkgs: runtimeLibs ++ gstPlugins;

  extraBwrapArgs = [
    "--setenv" "GIO_EXTRA_MODULES" "${glib-networking}/lib/gio/modules"
    "--setenv" "GST_PLUGIN_PATH" (lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstPlugins)
  ];

  meta = {
    description = "Download Spotify tracks in FLAC format";
    homepage = "https://github.com/afkarxyz/SpotiFLAC";
    mainProgram = "spotiflac";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree;
  };
}
