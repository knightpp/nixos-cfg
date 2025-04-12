{
  lib,
  guile,
  stdenv,
  fetchFromGitea,
  pkg-config,
  callPackage,
  bash,
  makeWrapper,
}:
let
  srfi =
    {
      lib,
      stdenv,
      fetchFromGitea,
      mitscheme,
    }:

    stdenv.mkDerivation {
      pname = "srfi";
      version = "unstable-2023-06-04";

      src = fetchFromGitea {
        domain = "codeberg.org";
        owner = "rgherdt";
        repo = "srfi";
        rev = "e598c28eb78e9c3e44f5c3c3d997ef28abb6f32e";
        hash = "sha256-kvM2v/nDou0zee4+qcO5yN2vXt2y3RUnmKA5S9iKFE0=";
      };

      nativeBuildInputs = [
        guile
      ];

      buildInputs = [
        guile
      ];

      propagatedBuildInputs = [
        (callPackage irregex { })
      ];

      preConfigure = ''
        export GUILE_AUTO_COMPILE=0
      '';

      buildPhase = ''
        runHook preBuild

        site_dir="$out/share/guile/site/3.0"
        lib_dir="$out/lib/guile/3.0/site-ccache"

        export GUILE_LOAD_PATH=.:$site_dir:...:$GUILE_LOAD_PATH
        export GUILE_LOAD_COMPILED_PATH=.:$lib_dir:...:$GUILE_LOAD_COMPILED_PATH

        mkdir -p $site_dir/srfi
        cp $src/srfi/srfi-145.scm $site_dir/srfi
        cp $src/srfi/srfi-180.scm $site_dir/srfi
        cp -R $src/srfi/srfi-180/ $site_dir/srfi
        cp -R $src/srfi/180/ $site_dir/srfi
        guild compile -x "sld" --r7rs $site_dir/srfi/srfi-180/helpers.sld -o $lib_dir/srfi/srfi-180/helpers.go
        guild compile --r7rs $site_dir/srfi/srfi-180.scm -o $lib_dir/srfi/srfi-180.go

        runHook postBuild
      '';

      strictDeps = true;

      meta = {
        description = "Scheme SRFI implementations in portable R7RS scheme";
        homepage = "https://codeberg.org/rgherdt/srfi";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ knightpp ];
        platforms = lib.platforms.all;
      };
    };

  scheme-json-rpc =
    {
      lib,
      stdenv,
      fetchFromGitea,
    }:
    stdenv.mkDerivation (finalAttrs: {
      pname = "scheme-json-rpc";
      version = "0.4.5a";

      src = fetchFromGitea {
        domain = "codeberg.org";
        owner = "rgherdt";
        repo = "scheme-json-rpc";
        rev = finalAttrs.version;
        hash = "sha256-sTJxPxHKovMOxfu5jM/6EpB9RFpG+9E3388xeE2Fpgw=";
      };

      strictDeps = true;

      propagatedBuildInputs = [
        (callPackage srfi { })
      ];

      nativeBuildInputs = [
        pkg-config
        guile
      ];

      buildInputs = [
        guile
      ];

      env.GUILE_AUTO_COMPILE = "0";

      preConfigure = ''
        cd guile
      '';

      meta = {
        description = "A JSON-RPC implementation for Scheme";
        homepage = "https://codeberg.org/rgherdt/scheme-json-rpc";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ knightpp ];
        platforms = lib.platforms.all;
      };
    });

  irregex =
    {
      lib,
      stdenv,
      fetchzip,
      mitscheme,
    }:
    stdenv.mkDerivation (finalAttrs: {
      pname = "irregex";
      version = "0.9.11";

      src = fetchzip {
        url = "http://synthcode.com/scheme/irregex/irregex-${finalAttrs.version}.tar.gz";
        hash = "sha256-abBCMNsr6GTBOm+eQWuOX8JYx/qMA/V6TwGdYRjznWU=";
      };

      strictDeps = true;

      nativeBuildInputs = [
        guile
        mitscheme
      ];

      buildInputs = [
        guile
      ];

      env.GUILE_AUTO_COMPILE = "0";

      buildPhase = ''
        runHook preBuild

        site_dir="$out/share/guile/site/3.0"
        lib_dir="$out/lib/guile/3.0/site-ccache"

        mkdir -p $site_dir/rx/source
        mkdir -p $lib_dir/rx/source

        cp $src/irregex-guile.scm $site_dir/rx/irregex.scm
        cp $src/irregex.scm $site_dir/rx/source/irregex.scm
        cp $src/irregex-utils.scm $site_dir/rx/source/irregex-utils.scm
        guild compile --r7rs $site_dir/rx/irregex.scm -o $lib_dir/rx/irregex.go
        guild compile --r7rs $site_dir/rx/source/irregex.scm -o $lib_dir/rx/source/irregex.go

        runHook postBuild
      '';

      dontInstall = true;
    });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "guile-lsp-server";
  version = "0.4.7";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "rgherdt";
    repo = "scheme-lsp-server";
    tag = "${finalAttrs.version}";
    hash = "sha256-XNzon1l6CnCd4RasNrHHxWEBNhyaHXgdNLsvjvRLbfk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    guile
  ];

  buildInputs = [
    guile
  ];

  propagatedBuildInputs = [
    (callPackage scheme-json-rpc { })
  ];

  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];

  preConfigure = ''
    cd guile
  '';

  postInstall = ''
    wrapProgram $out/bin/guile-lsp-server \
      --prefix PATH : ${
        lib.makeBinPath [
          guile
          bash
        ]
      } \
      --set GUILE_AUTO_COMPILE 0 \
      --prefix GUILE_LOAD_PATH : "$out/${guile.siteDir}:$GUILE_LOAD_PATH" \
      --prefix GUILE_LOAD_COMPILED_PATH : "$out/${guile.siteCcacheDir}:$GUILE_LOAD_COMPILED_PATH" \
      --argv0 $out/bin/guile-lsp-server
  '';

  meta = {
    homepage = "https://codeberg.org/rgherdt/scheme-lsp-server";
    description = "An LSP server for Guile";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ knightpp ];
    mainProgram = "guile-lsp-server";
    platforms = guile.meta.platforms;
  };
})
