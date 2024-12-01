{
  description = "ShortCuts for Any Window Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, home-manager }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "i686-linux"
      ];
      forEachSystem = f: nixpkgs.lib.genAttrs systems f;
    in
    {
      homeManagerModules = rec {
        scawm = import ./modules;
        default = scawm;
      };
      homeConfigurations = forEachSystem (
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            self.homeManagerModules.scawm
            ./test
          ];
        }
      );
      devShells = forEachSystem (system: rec {
        scawm = nixpkgs.legacyPackages.${system}.mkShell {
          packages = with nixpkgs.legacyPackages.${system}; [
            nixd
            nixfmt-rfc-style
          ];
        };
        default = scawm;
      });
      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
