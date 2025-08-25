{ stdenv,
  lib,
  fetchurl,
  zstd,
  patchelf,
  freetype,
  ...
}:

# TODO: Use BuildFHSEnv instead
# Cant use patchelf or autoPatchelfHook due to static binary
stdenv.mkDerivation rec {
  name = "sober";
  version = "2025-08-25";
  src = fetchurl {
    url = "https://sober.vinegarhq.org/artifacts/${version}_c82d94b/6ae8bb6f8194b8fe57257477abf29d537c4bddaa15122a8f9c9761146a54aed1/sober-binaries-unified.tar.zst";
    hash = "sha256-aui7b4GUuP5XJXR3q/KdU3xL3aoVEiqPnJdhFGpUrtE=";
  };

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontPatchELF = true;  # Quan trọng: không patch ELF

  nativeBuildInputs = [
    zstd
  ];

  buildInputs = [
    freetype
  ];

  unpackPhase = ''
    zstd -d < $src | tar xf -
  '';

  installPhase = ''
    install -Dm755 sober -t $out/bin/
    install -Dm755 sober_services -t $out/bin/
    install -Dm644 org.vinegarhq.Sober.metainfo.xml -t $out/share/metainfo/
    install -Dm644 org.vinegarhq.Sober.desktop $out/share/applications/org.vinegarhq.Sober.desktop
    install -Dm644 sober.svg $out/share/icons/hicolor/scalable/apps/org.vinegarhq.Sober.svg
  '';

  postFixup = ''
    # Thử patchelf cho từng binary
    if [ -f "$out/bin/sober" ]; then
      patchelf --set-rpath "${lib.makeLibraryPath [ freetype ]}:$out/lib" \
               "$out/bin/sober" || true
    fi

    if [ -f "$out/bin/sober_services" ]; then
      patchelf --set-rpath "${lib.makeLibraryPath [ freetype ]}:$out/lib" \
               "$out/bin/sober_services" || true
    fi
  '';
}
