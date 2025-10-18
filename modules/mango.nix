{
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    optionalString
    hasInfix
    replaceStrings
    concatMapAttrsStringSep
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
  type = "mango";
  cfg = integrations.${type};
  concatMapAttrLines = concatMapAttrsStringSep "\n";
  mkKeys = n: (if (hasInfix " " n) then (replaceStrings [ " " ] [ "," ] n) else "NONE,${n}");
  mkSpawn = s: "spawn,${s}";
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
          + (optionalString (v ? switch) (mapVals (v: "spawn,${v}") v.switch))
          + (optionalString (v ? switch) (mapVals (_: "setkeymode,default") v.switch))
          + (optionalString (v ? stay) (mapVals mkSpawn v.stay))
        ) (mapMod (modes type))}

        keymode=default
        ${mapVals mkSpawn (mapMod (defmode type))}
        ${mapVals (v: "setkeymode,${v.name}") (mapMod (modes type))}
      '';
    };
  };
}
