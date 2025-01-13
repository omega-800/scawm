{ lib, config, ... }:
let
  inherit (lib)
    mkIf
    toLower
    mapAttrs'
    nameValuePair
    concatMapAttrs
    optionalAttrs
    replaceStrings
    ;
  inherit (config.scawm)
    integrations
    ;
  inherit (import ./lib.nix { inherit lib config; })
    modes
    defmode
    modeNames
    mkIntegration
    mapAttrNamesRec
    spcToPlus'
    ;
  cfg = integrations.sxhkd;
  # TODO: change all modifiers
  mapMod = kb: mapAttrNamesRec (replaceStrings [ "Mod4" ] [ "super" ]) kb;
  mapLower = kb: mapAttrNamesRec toLower kb;
  mapAll = kb: mapMod (mapLower (spcToPlus' kb));
in
{
  options.scawm.integrations.sxhkd = mkIntegration "sxhkd";
  config = mkIf cfg.enable {
    services.sxhkd.keybindings =
      (mapAll defmode)
      // (concatMapAttrs (
        n: v:
        (optionalAttrs (v ? switch) (mapAttrs' (n': v': nameValuePair "${n} ; ${n'}" v') v.switch))
        // (optionalAttrs (v ? stay) (mapAttrs' (n': v': nameValuePair "${n} : ${n'}" v') v.stay))
      ) (mapAll modes));
  };
}
