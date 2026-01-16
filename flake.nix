{
  description = "Declarative MCP server management for Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }:
    flake-utils.lib.eachDefaultSystem
      (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          # Development shell
          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.nixpkgs-fmt
              pkgs.statix
              pkgs.deadnix
              pkgs.nil
            ];
          };

          # Checks (run with `nix flake check`)
          checks = {
            format = pkgs.runCommand "check-format" { } ''
              ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}
              touch $out
            '';
          };

          # Formatter (run with `nix fmt`)
          formatter = pkgs.nixpkgs-fmt;
        }
      )
    // {
      # Home Manager module
      homeManagerModules = {
        default = self.homeManagerModules.mcp;
        mcp = import ./modules/default.nix;
      };
    };
}
