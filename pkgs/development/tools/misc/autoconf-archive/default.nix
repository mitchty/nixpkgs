{ stdenv, fetchurl, xz }:
stdenv.mkDerivation rec {
  name = "autoconf-archive-${version}";
  version = "2015.09.25";

  src = fetchurl {
    url = "mirror://gnu/autoconf-archive/autoconf-archive-${version}.tar.xz";
    sha256 = "02im1jn0igzn2qpxkgiwxvcm3jgvjaypg955pi9h2d6jvfjnf13w";
  };
  buildInputs = [ xz ];

  meta = with stdenv.lib; {
    description = "Archive of autoconf m4 macros";
    homepage = http://www.gnu.org/software/autoconf-archive/;
    license = licenses.gpl3;
  };
}
