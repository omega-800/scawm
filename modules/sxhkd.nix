{ lib, config, ... }:
let
  inherit (lib)
    replaceStrings
    concatMapAttrs
    nameValuePair
    optionalAttrs
    mapAttrs'
    mkIf
    ;
  inherit (config.scawm) integrations;
  inherit (import ./lib.nix { inherit lib config; })
    mapAttrNamesRec
    mkIntegration
    bindingsCfg
    topLvlBinds
    modeBinds
    ;
  type = "sxhkd";
  cfg = integrations.${type};
  spcToPlus' = kb: mapAttrNamesRec (replaceStrings [ "+" " " ] [ " + " " + " ]) kb;
  mapMod = mapAttrNamesRec (
    replaceStrings
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
  );
  mapAll = kb: mapMod (spcToPlus' kb);
  mapKeybinds =
    p: a:
    (mapAttrs' (n': nameValuePair "${p}${n'}") (topLvlBinds a))
    // (concatMapAttrs (
      n: v:
      (optionalAttrs (v ? switch) (mapKeybinds "${p}${n} ; " (mapAll v.switch)))
      // (optionalAttrs (v ? stay) (mapKeybinds "${p}${n} : " (mapAll v.stay)))
    ) (modeBinds a));
in
{
  options.scawm.integrations.${type} = mkIntegration type;
  config = mkIf cfg.enable {
    services.${type}.keybindings = mapKeybinds "" (mapAll (bindingsCfg type));
  };
}
