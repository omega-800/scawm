{ lib, config, ... }:
let
  inherit (lib)
    mkIf
    mapAttrs'
    nameValuePair
    mapAttrs
    optionalAttrs
    hasInfix
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
    ;
  cfg = integrations.river;
  mkName = n: (if (hasInfix " " n) then n else "None ${n}");
  mapVals = f: a: mapAttrs' (n: v: nameValuePair (mkName n) (f v)) a;
  escape' = s: replaceStrings [ "'" ] [ "\\'" ] s;
in
{
  options.scawm.integrations.river = mkIntegration "river";
  config = mkIf cfg.enable {
    wayland.windowManager.river.settings = {
      declare-mode = modeNames;
      map =
        {
          normal = (mapVals (v: v) defmode) // (mapVals (v: "enter-mode ${v.name}") modes);
        }
        // (mapAttrs' (
          _: v:
          nameValuePair v.name (
            (optionalAttrs (v ? switch) (
              mapVals (v: "enter-mode normal && riverctl spawn '${escape' v}'") v.switch
            ))
            // (optionalAttrs (v ? stay) (mapVals (v: "spawn '${escape' v}'") v.stay))
            // {
              "None Escape" = "enter-mode normal";
            }
          )
        ) modes);
    };
  };
}
