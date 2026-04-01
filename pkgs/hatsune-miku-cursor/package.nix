{ lib, stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation rec {
  pname = "hatsune-miku-cursor";
  version = "1.0";

  src = fetchzip {
  url = "https://github.com/mikuri12/my-lazy-nixos-pkgs/releases/download/cursores/Hatsune-Miku.tar.gz";
  hash = "sha256-CDkVpQU8oFmo3S0HYMmByvJ9SgRBiPo+2p6VrX473lI=";
  stripRoot = false;
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -r Hatsune-Miku $out/share/icons/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Hatsune Miku X11 cursor theme ported to Linux";
    longDescription = ''
      Hatsune Miku cursor theme originally by Noiire, ported to Linux.
      Source: https://www.gnome-look.org/p/2303818
    '';
    homepage = "https://www.gnome-look.org/p/2303818";
    license = licenses.free;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
