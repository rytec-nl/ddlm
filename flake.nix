{
  inputs = {
    naersk.url = "github:nmattia/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , utils
    , naersk
    , ...
    }:
    utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      naersk-lib = pkgs.callPackage naersk { };
    in
    {
      defaultPackage = naersk-lib.buildPackage ./.;

      defaultApp = utils.lib.mkApp {
        drv = self.defaultPackage."${system}";
      };

      devShell = with pkgs;
        mkShell rec {
          buildInputs = [
            cargo
            rustc
            rustfmt
            rust-analyzer
            pre-commit
            rustPackages.clippy
            cargo-supply-chain
          ];

          RUST_SRC_PATH = rustPlatform.rustLibSrc;
          LD_LIBRARY_PATH = "${lib.makeLibraryPath buildInputs}";
        };
    });
}
