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
  version = "1.6.7";
  nativeBuildInputs = [ git ];
  src = fetchFromGitHub {
    owner = "bulwarkmail";
    repo = "webmail";
    tag = "${finalAttrs.version}";
    hash = "sha256-lKje0UDhO33JlsOi94u81kBGtAR7K2mQhxDOBbz9hKw=";
  };

  npmDepsHash = "sha256-1fieu0zN8qjmTEt3jlAVEH+83A37xTLSrrF46KWyUNc=";
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
