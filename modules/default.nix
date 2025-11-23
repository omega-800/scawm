{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkOption;
  inherit (lib.types) str;
  inherit (import ./lib.nix { inherit lib config; }) bindings;
in
{
  imports = [
    ./river.nix
    ./sway.nix
    ./sxhkd.nix
    ./mango.nix
  ];
  options.scawm = {
    inherit bindings;
    enable = mkEnableOption "ShortCuts for Any Window Manager";
    autoEnable = mkEnableOption "Autoconfiguration of your shortcuts for every available wm / compositor";
    modifier = mkOption {
      type = str;
      description = "Main modifier key";
      default = "Mod4";
    };
  };
}
