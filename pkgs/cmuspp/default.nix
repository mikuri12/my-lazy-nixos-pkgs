{ lib
, stdenv
, fetchFromGitHub
, libsndfile
, alsa-lib
, libpng
, libjpeg
}:

stdenv.mkDerivation rec {
  pname = "cmuspp";
  version = "unstable-2025";

  src = fetchFromGitHub {
    owner = "Ars-byte";
    repo  = "cmuspp";
    rev   = "5410db86e8298803ec7b79e281a6a4d7613b421c";
    hash  = "sha256-rLsfZHHYv38+IHqnf2g6/yEFGMzOaW+TMR1SrZNt7VQ=";
  };

  buildInputs = [ libsndfile alsa-lib libpng libjpeg ];

  buildPhase = ''
    runHook preBuild
    g++ main.cpp -o cmuspp \
      -std=c++17 -O3 -pthread \
      -DCMUSPP_HAS_JPEG -DCMUSPP_HAS_PNG \
      -lsndfile -lpng -ljpeg -lasound
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 cmuspp $out/bin/cmuspp
    if [ -d themes ]; then
      cp -r themes $out/share/cmuspp/themes
    fi
    runHook postInstall
  '';

  meta = with lib; {
    description = "Small, fast and powerful C++17 terminal music player";
    homepage    = "https://github.com/Ars-byte/cmuspp";
    license     = licenses.mit;
    platforms   = platforms.linux;
    mainProgram = "cmuspp";
  };
}
