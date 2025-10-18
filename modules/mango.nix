{ inputs, lib, config, ... }:
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
    ;
  type = "mango";
  cfg = integrations.${type};
  concatMapAttrLines = concatMapAttrsStringSep "\n";
  mkKeys = n: (if (hasInfix " " n) then (replaceStrings [ " " ] [ "," ] n) else "NONE,${n}");
  mkSpawn = s: "spawn,${s}";
  mapVals = f: concatMapAttrLines (n: v: "bind=" + (mkKeys n) + "," + (f v));
in
{
  options.scawm.integrations.${type} = mkIntegration type;
  imports = [ inputs.mango.hmModules.mango ];
  config = mkIf cfg.enable {
    wayland.windowManager.${type} = {
      settings = ''
        keymode=common
        bind=NONE,Escape,setkeymode,default

        keymode=default
        ${mapVals mkSpawn (defmode type)}
        ${mapVals (v: "setkeymode,${v.name}") (modes type)}

        ${concatMapAttrLines (
          _: v:
          "keymode=${v.name}\n"
          + (optionalString (v ? switch) (mapVals (v: "spawn,setkeymode default && ${v}") v.switch))
          + (optionalString (v ? stay) (mapVals mkSpawn v.stay))
        ) (modes type)}
      '';
    };
  };
}
