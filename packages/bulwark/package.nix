{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  git,
  geist-font,

  defaultHostname ? "127.0.0.1",
  defaultPort ? 3000,
}:
buildNpmPackage (finalAttrs: {
  pname = "bulwark";
  version = "1.7.2";
  nativeBuildInputs = [ git ];
  src = fetchFromGitHub {
    owner = "bulwarkmail";
    repo = "webmail";
    tag = "${finalAttrs.version}";
    hash = "sha256-M5EgANzzBAVqQ+XdOQnoXlD3CyYCRcO0PiC6INrnqq8=";
  };

  npmDepsHash = "sha256-9yBNDbgq5C//tnWH4itx3AHaDW892G/KmBZ+R9J64Zw=";
  npmPackFlags = [ "--ignore-scripts" ];
  NODE_OPTIONS = [ "--openssl-legacy-provider" ];

  patches = [
    ./0001-use-local-google-fonts.patch
  ];

  preBuild = ''
    # TODO: BASE_PATH  
    cp ${geist-font}/share/fonts/opentype/Geist{,Mono}-Regular.otf ./app/ 
  '';

  postBuild = ''
    sed -i '1s|^|#!/usr/bin/env node \n|' .next/standalone/server.js
    patchShebangs .next/standalone/server.js
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{share,bin}

    cp -r .next/standalone $out/share/homepage/
    cp -r .next/standalone $out/share/homepage/data/
    # cp -r .env $out/share/homepage/
    cp -r public $out/share/homepage/public

    mkdir -p $out/share/homepage/.next
    cp -r .next/static $out/share/homepage/.next/static

    # https://github.com/vercel/next.js/discussions/58864
    ln -s /var/cache/bulwark $out/share/homepage/.next/cache
    # also provide a environment variable to override the cache directory
    substituteInPlace $out/share/homepage/node_modules/next/dist/server/image-optimizer.js \
        --replace '_path.join)(distDir,' '_path.join)(process.env["NEXT_CACHE_DIR"] || distDir,'

    chmod +x $out/share/homepage/server.js

    # we set a default port to support "nix run ..."
    makeWrapper $out/share/homepage/server.js $out/bin/bulwark \
      --set-default PORT ${toString defaultPort} \
      --set-default HOSTNAME ${defaultHostname}  \

    runHook postInstall
  '';

  meta = {
    description = "Bulwark JMAP Webmail :3";
    homepage = "https://bulwarkmail.org";
    license = lib.licenses.agpl3Only;
  };
})
