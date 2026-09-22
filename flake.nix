{
  description = "Hashicorp Nomad";

  # To generate a derivation per architecture
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    {
      # We define first an overlay, i.e. a definition of new packages as recommended in
      # https://discourse.nixos.org/t/how-to-consume-a-eachdefaultsystem-flake-overlay/19420/9
      overlays.default = final: prev: {
        nomad = final.callPackage (
          { stdenv, pkgs, ... }:
          # You can put here the derivation to build your program, for instance:
          pkgs.buildGoModule {
            src = pkgs.fetchFromGitHub {
              owner = "hashicorp";
              repo = "nomad";
              rev = "v2.0.7";
              fetchSubmodules = true;
              sha256 = "sha256-JOcN8Xyey84R2oA1lr9f6k/aNY1AJreig3fP3IM9C1M=";
            };
            pname = "nomad";
            version = "2.0.7";
            vendorHash = "sha256-5/ziFzfTgjtvRWCEZoRQMA+1BeAwJwWV9R5C4jSFuPA=";

            ldflags = [
              "-X github.com/hashicorp/nomad/version.Version=2.0.7"
              "-X github.com/hashicorp/nomad/version.VersionPrerelease="
              "-X github.com/hashicorp/nomad/version.BuildDate=1970-01-01T00:00:00Z"
            ];

            subPackages = [ "." ];

            tags = [ "ui" ];

            postInstall = ''
                      echo "complete -C $out/bin/nomad nomad" > nomad.bash
                      installShellCompletion nomad.bash
                    '';

            buildInputs = with pkgs; [
              go
              git
            ];
            nativeBuildInputs = with pkgs; [ installShellFiles ];
          }
        ) { };
      };
    }
    # We now add the package defined in the above overlay for all architectures
    // (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          system = system;
          overlays = [ self.overlays.default ];
        };
        lib = nixpkgs.lib;
      in
      {
        # Create a new package
        packages = {
          nomad = pkgs.nomad;
          default = self.packages.${system}.nomad; # default program: this way, typing "nix develop" will directly put you in a shell needed to develop the above your program, running "nix build/run" will directly build/run this program etc.
        };
      }
    ));
}
