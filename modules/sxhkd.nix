{ lib, config, ... }:
let
  inherit (lib)
    mkIf
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
    mkIntegration
    mapAttrNamesRec
    ;
  type = "sxhkd";
  cfg = integrations.${type};
  spcToPlus' = kb: mapAttrNamesRec (replaceStrings [ "+" " " ] [ " + " " + " ]) kb;
  mapMod =
    kb:
    mapAttrNamesRec (replaceStrings
      [
        "Mod4"
        "Mod"
        "Alt"
        "Ctrl"
        "Shift"
      ]
      [
        "super"
        "mod"
        "alt"
        "ctrl"
        "shift"
      ]
    ) kb;
  mapAll = kb: mapMod (spcToPlus' kb);
in
{
  options.scawm.integrations.${type} = mkIntegration type;
  config = mkIf cfg.enable {
    services.${type}.keybindings =
      (mapAll (defmode type))
      // (concatMapAttrs (
        n: v:
        (optionalAttrs (v ? switch) (mapAttrs' (n': nameValuePair "${n} ; ${n'}") v.switch))
        // (optionalAttrs (v ? stay) (mapAttrs' (n': nameValuePair "${n} : ${n'}") v.stay))
      ) (mapAll (modes type)));
  };
}
