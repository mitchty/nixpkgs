{ stdenv, fetchurl, python, pyqt5, sip_4_16, poppler_utils, pkgconfig, libpng
, imagemagick, libjpeg, fontconfig, podofo, qtbase, icu, sqlite
, makeWrapper, unrarSupport ? false, chmlib, pythonPackages, xz, libusb1, libmtp
, xdg_utils
}:

stdenv.mkDerivation rec {
  version = "2.53.0";
  name = "calibre-${version}";

  src = fetchurl {
    url = "http://download.calibre-ebook.com/${version}/${name}.tar.xz";
    sha256 = "0rvfh39a6j5r398p6xzrbzvhxapm1iyhc0d46xk5fwa52kscadhz";
  };

  inherit python;

  patches = [
    # Patch from Debian that switches the version update change from
    # enabled by default to disabled by default.
    ./no_updates_dialog.patch
  ] ++ stdenv.lib.optional (!unrarSupport) ./dont_build_unrar_plugin.patch;

  prePatch = ''
    sed -i "/pyqt_sip_dir/ s:=.*:= '${pyqt5}/share/sip':"  \
      setup/build_environment.py
  '';

  nativeBuildInputs = [ makeWrapper pkgconfig ];

  buildInputs =
    [ python pyqt5 sip_4_16 poppler_utils libpng imagemagick libjpeg
      fontconfig podofo qtbase chmlib icu sqlite libusb1 libmtp xdg_utils
      pythonPackages.mechanize pythonPackages.lxml pythonPackages.dateutil
      pythonPackages.cssutils pythonPackages.beautifulsoup pythonPackages.pillow
      pythonPackages.sqlite3 pythonPackages.netifaces pythonPackages.apsw
      pythonPackages.cssselect
    ];

  installPhase = ''
    export HOME=$TMPDIR/fakehome
    export POPPLER_INC_DIR=${poppler_utils}/include/poppler
    export POPPLER_LIB_DIR=${poppler_utils}/lib
    export MAGICK_INC=${imagemagick}/include/ImageMagick
    export MAGICK_LIB=${imagemagick}/lib
    export FC_INC_DIR=${fontconfig}/include/fontconfig
    export FC_LIB_DIR=${fontconfig}/lib
    export PODOFO_INC_DIR=${podofo}/include/podofo
    export PODOFO_LIB_DIR=${podofo}/lib
    export SIP_BIN=${sip_4_16}/bin/sip
    python setup.py install --prefix=$out

    PYFILES="$out/bin/* $out/lib/calibre/calibre/web/feeds/*.py
      $out/lib/calibre/calibre/ebooks/metadata/*.py
      $out/lib/calibre/calibre/ebooks/rtf2xml/*.py"

    sed -i "s/env python[0-9.]*/python/" $PYFILES
    sed -i "2i import sys; sys.argv[0] = 'calibre'" $out/bin/calibre

    for a in $out/bin/*; do
      wrapProgram $a --prefix PYTHONPATH : $PYTHONPATH \
                     --prefix PATH : ${poppler_utils}/bin
    done
  '';

  meta = with stdenv.lib; {
    description = "Comprehensive e-book software";
    homepage = http://calibre-ebook.com;
    license = with licenses; if unrarSupport then unfreeRedistributable else gpl3;
    maintainers = with maintainers; [ viric iElectric pSub AndersonTorres ];
    platforms = platforms.linux;
    inherit version;
  };
}
