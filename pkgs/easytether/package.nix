{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
  openssl_1_1,
  bluez,
}:
stdenv.mkDerivation rec {
  pname = "easytether";
  version = "0.8.9";

  src = fetchzip {
    url = "http://www.mobile-stream.com/beta/arch/${pname}-${version}-1-x86_64.pkg.tar.xz";
    sha256 = "sha256-3dL5tNxa1hou0SunXOcf0Wkh//hNfzbuI2Dnmk/ibns=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    openssl_1_1
    bluez
  ];

installPhase = ''
  runHook preInstall

  mkdir -p $out/bin $out/lib/udev/rules.d $out/lib/systemd/system

  install -m755 -D usr/bin/${pname}-usb        $out/bin/${pname}-usb
  install -m755 -D usr/bin/${pname}-bluetooth   $out/bin/${pname}-bluetooth
  install -m755 -D usr/bin/${pname}-local       $out/bin/${pname}-local

  install -m444 -D usr/lib/udev/rules.d/99-easytether-usb.rules \
    $out/lib/udev/rules.d/99-easytether-usb.rules

  install -m644 -D usr/lib/systemd/system/easytether-usb@.service \
    $out/lib/systemd/system/easytether-usb@.service

  runHook postInstall
'';

  meta = {
    description = "Share internet connection from Android to PC via USB or Bluetooth";
    homepage = "http://www.mobile-stream.com/easytether";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree;
  };
}
