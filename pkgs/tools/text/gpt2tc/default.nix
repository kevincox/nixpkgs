{ lib, stdenv, fetchurl, autoPatchelfHook, python3 }:

stdenv.mkDerivation rec {
  pname = "gpt2tc";
  version = "2020-12-30";

  src = fetchurl {
    url = "https://bellard.org/nncp/gpt2tc-${version}.tar.gz";
    hash = "sha256-KFcl7E6iGx50JaJI1jwzKAdkrkbNngPbrEA/ZSyG+uY=";
  };

  patches = [
    # Add a shebang to the python script so that nix detects it as such and
    # wraps it properly. Otherwise, it runs in shell and freezes the system.
    ./0001-add-python-shebang.patch

    # Update the source URL for the models because the old one is down.
    ./0002-fix-download-url.patch
  ];

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    (python3.withPackages (p: with p; [ numpy tensorflow ]))
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -D -m755 -t $out/bin gpt2tc
    install -T -m755 download_model.sh $out/bin/gpt2-download-model
    install -T -m755 gpt2convert.py $out/bin/gpt2-convert
    install -D -m644 -t $out/share/gpt2tc readme.txt gpt2vocab.txt Changelog

    runHook postInstall
  '';

  meta = with lib; {
    description = "Text completion and compression using GPT-2";
    homepage = "https://bellard.org/nncp/gpt2tc.html";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ anna328p ];
  };
}
