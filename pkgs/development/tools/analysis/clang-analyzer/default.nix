{ stdenv, fetchurl, clang, llvmPackages, perl, makeWrapper }:

stdenv.mkDerivation rec {
  name    = "clang-analyzer-${version}";
  version = "3.7.0";

  src = fetchurl {
    url    = "http://llvm.org/releases/${version}/cfe-${version}.src.tar.xz";
    sha256 = "1k517b0jj74c4vgnnd4ikbrpb96na541bi8q845ckw8xm72l1msf";
  };

  patchPhase = ''
    sourceRoot=$PWD/cfe-${version}
  '';

  patches = [ ./0001-Fix-scan-build-to-use-NIX_CFLAGS_COMPILE.patch ];
  buildInputs = [ clang llvmPackages.clang perl makeWrapper ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/libexec
    cp -R tools/scan-view  $out/libexec
    cp -R tools/scan-build $out/libexec

    makeWrapper $out/libexec/scan-view/scan-view $out/bin/scan-view
    makeWrapper $out/libexec/scan-build/scan-build $out/bin/scan-build \
      --add-flags "--use-cc=${clang}/bin/clang" \
      --add-flags "--use-c++=${clang}/bin/clang++" \
      --add-flags "--use-analyzer='${llvmPackages.clang}/bin/clang'"
  '';

  meta = {
    description = "Clang Static Analyzer";
    homepage    = "http://clang-analyzer.llvm.org";
    license     = stdenv.lib.licenses.bsd3;
    platforms   = stdenv.lib.platforms.unix;
    maintainers = [ stdenv.lib.maintainers.thoughtpolice ];
  };
}
