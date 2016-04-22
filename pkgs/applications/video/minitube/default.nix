{ stdenv, fetchFromGitHub, makeWrapper, phonon, phonon_backend_vlc, qt4, qmake4Hook
# "Free" API key generated by nckx <tobias.geerinckx.rice@gmail.com>
, withAPIKey ? "AIzaSyBtFgbln3bu1swQC-naMxMtKh384D3xJZE" }:

stdenv.mkDerivation rec {
  name = "minitube-${version}";
  version = "2.4";

  src = fetchFromGitHub {
    sha256 = "0mm8v2vpspwxh2fqaykb381v6r9apywc1b0x8jkcbp7s43w10lp5";
    rev = version;
    repo = "minitube";
    owner = "flaviotordini";
  };

  buildInputs = [ phonon phonon_backend_vlc qt4 ];
  nativeBuildInputs = [ makeWrapper qmake4Hook ];

  qmakeFlags = [ "DEFINES+=APP_GOOGLE_API_KEY=${withAPIKey}" ];

  enableParallelBuilding = true;

  postInstall = ''
    wrapProgram $out/bin/minitube \
      --prefix QT_PLUGIN_PATH : "${phonon_backend_vlc}/lib/kde4/plugins"
  '';

  meta = with stdenv.lib; {
    description = "Stand-alone YouTube video player";
    longDescription = ''
      Watch YouTube videos in a new way: you type a keyword, Minitube gives
      you an endless video stream. Minitube is not about cloning the YouTube
      website, it aims to create a new TV-like experience.
    '';
    homepage = http://flavio.tordini.org/minitube;
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ nckx ];
  };
}
