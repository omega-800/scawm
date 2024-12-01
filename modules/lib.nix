{ lib, config, ... }:
let
  inherit (lib)
    filterAttrs
    mapAttrsToList
    mapAttrs
    mapAttrs'
    nameValuePair
    types
    mkOption
    ;
  inherit (builtins) isAttrs isString replaceStrings;
  inherit (config.scawm)
    bindings
    autoEnable
    ;
in
rec {
  mkIntegration = wm: {
    enable = mkOption {
      description = "Enables shortcuts for ${wm}";
      type = types.bool;
      default = autoEnable;
    };
  };
  modes = filterAttrs (_: v: (isAttrs v) && (v ? name)) bindings;
  modeNames = mapAttrsToList (_: v: v.name) modes;
  defmode = filterAttrs (_: isString) bindings;
  spcToPlus = kb: mapAttrs' (n: v: nameValuePair (replaceStrings [ " " ] [ "+" ] n) (if (isAttrs v) then (spcToPlus v) else v)) kb;
}
