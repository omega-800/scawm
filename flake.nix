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
    {
      self,
      nixpkgs,
      home-manager,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "i686-linux"
      ];
      forEachSystem = f: nixpkgs.lib.genAttrs systems f;
      mkPkgs = system: import nixpkgs { inherit system; };
    in
    {
      homeManagerModules = rec {
        scawm = ./modules;
        default = scawm;
      };
      homeConfigurations = forEachSystem (
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          modules = [
            self.homeManagerModules.scawm
            ./test
          ];
        }
      );
      devShells = forEachSystem (
        system:
        let
          pkgs = mkPkgs system;
        in
        rec {
          scawm = pkgs.mkShell {
            packages = with pkgs; [
              nixd
              nixfmt-rfc-style
            ];
          };
          default = scawm;
        }
      );
      formatter = forEachSystem (system: (mkPkgs system).nixfmt-rfc-style);
    };
}
