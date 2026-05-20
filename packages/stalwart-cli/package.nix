{
  lib,
  rustPlatform,
  versionCheckHook,
  stalwart,
  fetchFromGitHub,
  openssl,
  pkg-config,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "stalwart-cli"; 
  version = "1.0.7";
  src = fetchFromGitHub {
    owner = "stalwartlabs";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "";
  };

  cargoHash = "";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  env.OPENSSL_NO_VENDOR = true;

  cargoBuildFlags = [
    "--package"
    "stalwart-cli"
  ];
  cargoTestFlags = [
    "--package"
    "stalwart-cli"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Stalwart Mail Server CLI";
    mainProgram = "stalwart-cli";
    homepage = "https://github.com/stalwartlabs/cli";
    changelog = "https://github.com/stalwartlabs/cli/blob/main/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    # maintainers = with lib.maintainers; [
    #   giomf
    # ];
  };
})
