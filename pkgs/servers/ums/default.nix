{
  maven,
  buildMaven,
  fetchgit,
  jre,
  libmediainfo,
  libzen,
  makeWrapper,
  stdenv,
}:

let
  mvn = buildMaven ./project-info.json;

  # To regenerate project info change this to true and build with network.
  # The output will be the project info JSON.
  createProjectInfo = false;
in stdenv.mkDerivation rec {
  name = "ums-${version}";
  # version = "6.7.3";
  # version = "c4119907f355050fe87707749116afa43f0544a4";
  version = "4f2a3046f92b909dab8cd697606b29953b196da9";

  src = fetchgit {
    url = "https://github.com/UniversalMediaServer/UniversalMediaServer.git";
    rev = version;
    # sha256 = "1nynzbwdzih3z55s19y2l8vzqg3m38gcjdyjxwr42kj2l219j6jh";
    sha256 = "1h92zx3gx6j9izr5y0ksmrn5liycrjnkkvd2w79lg6711v7ipnyh";
    leaveDotGit = true;
    deepClone = true;
  };

  buildInputs = [ jre makeWrapper maven ];

  buildPhase = if createProjectInfo then ''
    mvn -U -Dmaven.repo.local=$(mktemp -d -t nix-maven-XXXXXX) \
      org.nixos.mvn2nix:mvn2nix-maven-plugin:mvn2nix
    cp project-info.json $out
    exit
  '' else ''
    # Add -Doffline
    mvn --offline --settings ${mvn.settings} \
      -Doffline -Dmaven.test.skip.exec=true \
      prepare-package assembly:single@make-jar-with-dependencies-linux
  '';

  installPhase = ''
    mkdir -p "$out/bin/" "$out/lib/"
    cp -a src/main/external-resources/* "$out/lib"
    chmod +x "$out/lib/UMS.sh"
    cp target/*.jar $out/lib/ums.jar

    makeWrapper "$out/lib/UMS.sh" "$out/bin/ums" \
      --prefix LD_LIBRARY_PATH ":" "${stdenv.lib.makeLibraryPath [ libzen libmediainfo] }" \
      --set JAVA_HOME "${jre}"
  '';

  meta = {
      description = "Universal Media Server: a DLNA-compliant UPnP Media Server";
      license = stdenv.lib.licenses.gpl2;
      platforms = stdenv.lib.platforms.linux;
      maintainers = [ stdenv.lib.maintainers.thall ];
  };
}
