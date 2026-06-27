{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
buildGoModule rec {
  pname = "meowfetch";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "faynopi";
    repo = "meowfetch";
    rev = "e5424bec2395f37a654b5f0531f0baaaac6b642b";
    hash = "sha256-2T1kimxrg4SfuWDx17N5SKmdvybHOXy4a4bXf80+09U=";
  };

  vendorHash = "sha256-PnkXXNr+kIige1YB/vEG+sYI0X/rr+6Gtcnb0rW4YK0=";

  subPackages = ["."];

  ldflags = [
    "-s"
    "-w"
  ];

  nativeBuildInputs = [installShellFiles];

  postInstall = ''
    mkdir -p $out/share/man/man1
    sed "s/{VERSION}/${version}/g" < meowfetch.1 > $out/share/man/man1/meowfetch.1

    mkdir -p $out/share/meowfetch
    cp configs/meow.conf $out/share/meowfetch/meow.conf
  '';

  meta = with lib; {
    description = "Minimal, fast and customizable system information fetcher written in Go";
    homepage = "https://github.com/faynopi/meowfetch";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.linux;
    mainProgram = "meowfetch";
  };
}
