{ lib, config, ... }:
let
  inherit (lib)
    replaceStrings
    nameValuePair
    optionalAttrs
    mapAttrs'
    isString
    hasInfix
    mkIf
    ;
  inherit (config.scawm)
    integrations
    ;
  inherit (import ./lib.nix { inherit lib config; })
    mkIntegration
    topLvlModes
    modeNames
    defmode
    modes
    ;
  type = "river";
  cfg = integrations.${type};
  mkKeys = n: (if (hasInfix " " n) then n else "None ${n}");
  mkSpawn = s: "spawn '${escapeA s}'";
  mapVals = f: mapAttrs' (n: v: nameValuePair (mkKeys n) (f v));
  escapeA = replaceStrings [ "'" ] [ "'\\''" ];
in
{
  options.scawm.integrations.${type} = mkIntegration type;
  config = mkIf cfg.enable {
    wayland.windowManager.${type} = {
      settings = {
        declare-mode = modeNames type;
        map = {
          normal =
            (mapVals mkSpawn (defmode type)) // (mapVals (v: "enter-mode '${v.name}'") (topLvlModes type));
        }
        // (mapAttrs' (
          _: v:
          nameValuePair v.name (
            (optionalAttrs (v ? switch) (
              mapVals (
                v':
                if isString v' then
                  "spawn 'riverctl enter-mode normal && ${escapeA v'}'"
                else
                  "enter-mode '${v'.name}'"
              ) v.switch
            ))
            // (optionalAttrs (v ? stay) (
              mapVals (v': if isString v' then mkSpawn v' else "enter-mode '${v'.name}'") v.stay
            ))
            // {
              "None Escape" = "enter-mode normal";
            }
          )
        ) (modes type));
      };
    };
  };
}
