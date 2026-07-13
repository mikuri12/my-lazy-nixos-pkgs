{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  copyDesktopItems,
  makeDesktopItem,
  # Runtime deps de Electron/Chromium
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libGL,
  libdrm,
  libgbm,
  libnotify,
  libpulseaudio,
  libuuid,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
  xorg,
}:
stdenv.mkDerivation rec {
  pname = "fluxer";
  version = "0.0.8";

  # OJO: la URL es "latest", así que cuando Fluxer publique una versión nueva
  # el hash dejará de coincidir. Al actualizar: subir version, borrar el hash y
  # copiar el nuevo que reporte el error del build.
  src = fetchurl {
    url = "https://api.fluxer.app/dl/desktop/stable/linux/x64/latest/tar_gz";
    # La URL no acaba en .tar.gz, así que hay que nombrar el archivo a mano
    # para que unpackPhase sepa descomprimirlo.
    name = "fluxer-${version}.tar.gz";
    hash = "sha256-rPY5j6aBByD+2FsGwBGzJOfbT+xr8vx62TwkRsNgDy0=";
  };

  # El bundle vive en un subdirectorio fluxer-stable-<ver>-x64/.
  sourceRoot = "fluxer-stable-${version}-x64";

  # El binario y las .so ya vienen compilados: solo hay que parchear rpaths.
  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
    copyDesktopItems
  ];

  # Libs contra las que se enlaza el binario Electron.
  buildInputs =
    [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libdrm
      libgbm
      libnotify
      libuuid
      libxkbcommon
      mesa
      nspr
      nss
      pango
      (lib.getLib stdenv.cc.cc) # libstdc++
    ]
    ++ (with xorg; [
      libX11
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXi
      libXrandr
      libXrender
      libXScrnSaver
      libXt
      libXtst
      libxcb
      libxshmfence
    ]);

  # Libs que se resuelven en runtime (dlopen) y se inyectan vía wrapper.
  runtimeDependencies = [
    (lib.getLib systemd) # libudev
    libGL
    libpulseaudio
  ];

  # El tar.gz es un bundle plano, no un sistema de build.
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Todo el bundle va a libexec; el binario se expone vía wrapper en bin.
    mkdir -p $out/libexec/fluxer $out/bin
    cp -r . $out/libexec/fluxer

    # chrome-sandbox necesita setuid; en Nix no se puede, se desactiva el sandbox
    # de suid y se usa el namespace sandbox de Chromium (userns de NixOS).
    rm -f $out/libexec/fluxer/chrome-sandbox

    # Icono para el menú de aplicaciones.
    install -Dm644 resources/512x512.png \
      $out/share/icons/hicolor/512x512/apps/fluxer.png

    runHook postInstall
  '';

  # gappsWrapperArgs se rellena por wrapGAppsHook3; se aplica al binario real.
  postFixup = ''
    makeWrapper $out/libexec/fluxer/fluxer $out/bin/fluxer \
      "''${gappsWrapperArgs[@]}" \
      --add-flags "--no-sandbox"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "fluxer";
      exec = "fluxer %U";
      icon = "fluxer";
      desktopName = "Fluxer";
      comment = "Chat de mensajería instantánea y VoIP para amigos y comunidades";
      categories = ["Network" "InstantMessaging" "Chat"];
      startupWMClass = "Fluxer";
      mimeTypes = ["x-scheme-handler/fluxer"];
    })
  ];

  meta = with lib; {
    description = "Cliente de escritorio de Fluxer (chat estilo Discord, libre y open source)";
    homepage = "https://fluxer.app";
    license = licenses.agpl3Only;
    platforms = ["x86_64-linux"];
    sourceProvenance = [sourceTypes.binaryNativeCode];
    mainProgram = "fluxer";
  };
}
