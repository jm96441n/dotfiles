{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  systemdLibs,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libxcb,
}:
# Prebuilt Electron app (zenbu-labs/terminal-browser); no upstream nix packaging.
stdenv.mkDerivation (finalAttrs: {
  pname = "terminal-browser";
  version = "0.16.3";

  src =
    let
      sources = {
        x86_64-linux = {
          url = "linux-x64";
          sha256 = "b66199f47ec18b00a47423cc8095dc06898eaed0c4f247a252cfce76388ea151";
        };
        aarch64-linux = {
          url = "linux-arm64";
          sha256 = "805201d715a6c684c8c1d5187d90639f077f8ffae68934e1197bcd0d13682037";
        };
      };
      src = sources.${stdenv.hostPlatform.system} or (throw "terminal-browser: unsupported system ${stdenv.hostPlatform.system}");
    in
    fetchurl {
      url = "https://github.com/zenbu-labs/terminal-browser/releases/download/v${finalAttrs.version}/terminal-browser-${src.url}.tar.gz";
      inherit (src) sha256;
    };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemdLibs
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/terminal-browser
    cp -r . $out/share/terminal-browser
    mkdir -p $out/bin
    ln -s $out/share/terminal-browser/bin/terminal-browser $out/bin/terminal-browser
    runHook postInstall
  '';

  meta = {
    description = "A browser that runs inside your terminal";
    homepage = "https://terminal-browser.com";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "terminal-browser";
  };
})
