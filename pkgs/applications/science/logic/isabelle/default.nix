{ stdenv, fetchurl, perl, nettools, java, polyml, z3 }:
# nettools needed for hostname

let
  dirname = "Isabelle2016-1";
in

stdenv.mkDerivation {
  name = "isabelle-2016-1";
  inherit dirname;

  src = if stdenv.isDarwin
    then fetchurl {
      url = "http://isabelle.in.tum.de/website-${dirname}/dist/${dirname}.dmg";
      sha256 = "0553l7m2z32ajmiv6sgg11rh16n490w8i4q9hr7vx4zzggr9nrlr";
    }
    else fetchurl {
      url = "http://isabelle.in.tum.de/website-${dirname}/dist/${dirname}_linux.tar.gz";
      sha256 = "1w1cgfmmi1sr43z6hczyc29lxlnlz7dd8fa88ai44wkc13y05b5r";
    };

  buildInputs = [ perl polyml z3 ]
             ++ stdenv.lib.optionals (!stdenv.isDarwin) [ nettools java ];

  sourceRoot = dirname;

  postPatch = ''
    ENV=$(type -p env)
    patchShebangs "."
    substituteInPlace lib/Tools/env \
      --replace /usr/bin/env $ENV
    substituteInPlace lib/Tools/install \
      --replace /usr/bin/env $ENV
    sed -i 's|isabelle_java java|${java}/bin/java|g' lib/Tools/java
    substituteInPlace etc/settings \
      --subst-var-by ML_HOME "${polyml}/bin"
    substituteInPlace contrib/jdk/etc/settings \
      --replace ISABELLE_JDK_HOME= '#ISABELLE_JDK_HOME='
    substituteInPlace contrib/polyml-*/etc/settings \
      --replace '$POLYML_HOME/$ML_PLATFORM' ${polyml}/bin \
      --replace '$POLYML_HOME/$PLATFORM/polyml' ${polyml}/bin/poly
    substituteInPlace lib/scripts/run-polyml* lib/scripts/polyml-version \
      --replace '$ML_HOME/poly' ${polyml}/bin/poly
    substituteInPlace contrib/z3*/etc/settings \
      --replace '$Z3_HOME/z3' '${z3}/bin/z3'
    '' + (if ! stdenv.isLinux then "" else ''
    arch=${if stdenv.system == "x86_64-linux" then "x86_64-linux" else "x86-linux"}
    for f in contrib/*/$arch/{bash_process,epclextract,eprover,nunchaku,SPASS}; do
      patchelf --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) "$f"
    done
    '');

  installPhase = ''
    mkdir -p $out/bin
    mv $TMP/$dirname $out
    cd $out/$dirname
    bin/isabelle install $out/bin
  '';

  meta = {
    description = "A generic proof assistant";

    longDescription = ''
      Isabelle is a generic proof assistant.  It allows mathematical formulas
      to be expressed in a formal language and provides tools for proving those
      formulas in a logical calculus.
    '';
    homepage = http://isabelle.in.tum.de/;
    license = "LGPL";
    maintainers = [ stdenv.lib.maintainers.jwiegley ];
    platforms = stdenv.lib.platforms.linux;
  };
}
