{
  fetchurl,
  pkgs,
  stdenv,
  ...  }:

stdenv.mkDerivation rec {
  name = "streama-${version}";
  version = "1.1";

  src = fetchurl {
    url = "https://github.com/dularion/streama/releases/download/v${version}/streama-${version}.war";
    sha256 = "1csdj2dn74ramx21pipmsyi81gyswj8nqrr3xh5p3gz79bzizyhz";
  };

  phases = "installPhase";

  installPhase = ''
    mkdir $out
    cp $src $out/streama.war
  '';

  meta = {
    description = "Host your own Streaming Application with your media library.";
    homepage = https://dularion.github.io/streama/;
    license = stdenv.lib.licenses.mit;
    maintainers = with stdenv.lib.maintainers; [ kevincox ];
    platforms = stdenv.lib.platforms.all;
  };
}
