{
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    concatMapAttrsStringSep
    replaceStrings
    optionalString
    hasInfix
    mkIf
    ;
  inherit (config.scawm)
    integrations
    ;
  inherit (import ./lib.nix { inherit lib config; })
    mapAttrNamesRec
    mkIntegration
    topLvlBinds
    topLvlModes
    modeBinds
    defmode
    modes
    ;
  type = "mango";
  cfg = integrations.${type};
  concatMapAttrLines = concatMapAttrsStringSep "\n";
  mkKeys = n: (if (hasInfix " " n) then (replaceStrings [ " " ] [ "," ] n) else "NONE,${n}");
  mkSpawn = s: "spawn,${s}";
  mkMode = s: "keymode,${s.name}";
  mapVals = f: concatMapAttrLines (n: v: "bind=" + (mkKeys n) + "," + (f v));
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
        "SUPER"
        "MOD"
        "ALT"
        "CTRL"
        "SHIFT"
      ]
  );
in
{
  options.scawm.integrations.${type} = mkIntegration type;
  imports = [ inputs.mango.hmModules.mango ];
  config = mkIf cfg.enable {
    wayland.windowManager.${type} = {
      settings = ''
        ${concatMapAttrLines (
          _: v:
          ''
            keymode=${v.name}
            bind=NONE,Escape,setkeymode,default
          ''
          + (optionalString (v ? switch) (mapVals mkMode (modeBinds v.switch)))
          + (optionalString (v ? switch) (mapVals mkSpawn (topLvlBinds v.switch)))
          + (optionalString (v ? switch) (mapVals (_: "setkeymode,default") (topLvlBinds v.switch)))
          + (optionalString (v ? stay) (mapVals mkMode (modeBinds v.stay)))
          + (optionalString (v ? stay) (mapVals mkSpawn (topLvlBinds v.stay)))
        ) (mapMod (modes type))}

        keymode=default
        ${mapVals mkSpawn (mapMod (defmode type))}
        ${mapVals mkMode (mapMod (topLvlModes type))}
      '';
    };
  };
}
