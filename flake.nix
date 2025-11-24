{
  description = "ShortCuts for Any Window Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mango = {
      url = "github:DreamMaoMao/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "i686-linux"
      ];
      eachSystem =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          (f (
            import nixpkgs {
              inherit system;
              config = { };
              overlays = [ ];
            }
          ))
        );
    in
    {
      homeModules = self.homeManagerModules;
      homeManagerModules =
        let
          scawm = ./modules;
        in
        {
          inherit scawm;
          default = scawm;
        };
      homeConfigurations = eachSystem (
        pkgs:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            self.homeManagerModules.scawm
            ./test
          ];
        }
      );
      devShells = eachSystem (
        pkgs:
        let
          scawm = pkgs.mkShell {
            packages = with pkgs; [
              nixd
              nixfmt-rfc-style
            ];
          };
        in
        {
          inherit scawm;
          default = scawm;
        }
      );
      formatter = eachSystem (pkgs: pkgs.nixfmt-rfc-style);
    };
}
