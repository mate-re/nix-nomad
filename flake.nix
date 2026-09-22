{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        nomad = pkgs.callPackage ./package.nix { };
        default = self.packages.${pkgs.system}.nomad;
      });

      overlays.default = final: prev: {
        nomad = final.callPackage ./package.nix { };
      };
    };
}
