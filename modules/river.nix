{ lib, config, ... }:
let
  inherit (lib)
    mkIf
    mapAttrs'
    nameValuePair
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
  type = "river";
  cfg = integrations.${type};
  mkKeys = n: (if (hasInfix " " n) then n else "None ${n}");
  mkSpawn = s: "spawn '${escapeA s}'";
  mapVals = f: mapAttrs' (n: v: nameValuePair (mkKeys n) (f v));
  escapeA = replaceStrings [ "'" ] [ "'\\''" ];
in
# concatImapAttrsLines =
#   f: a:
#   pipe a [
#     attrsToList
#     (imap (i: v: f i v.name v.value))
#     concatLines
#   ];
{
  options.scawm.integrations.${type} = mkIntegration type;
  config = mkIf cfg.enable {
    wayland.windowManager.${type} = {
      settings = {
        declare-mode = modeNames;
        map =
          {
            normal = (mapVals mkSpawn (defmode type)) // (mapVals (v: "enter-mode ${v.name}") (modes type));
          }
          // (mapAttrs' (
            _: v:
            nameValuePair v.name (
              (optionalAttrs (v ? switch) (
                mapVals (v: "spawn 'riverctl enter-mode normal && ${escapeA v}'") v.switch
              ))
              // (optionalAttrs (v ? stay) (mapVals mkSpawn v.stay))
              // {
                "None Escape" = "enter-mode normal";
              }
            )
          ) (modes type));
      };
      # extraConfig = concatImapAttrsLines (
      #   i: _: v:
      #   concatImapAttrsLines (
      #     i': keys: action:
      #     let
      #       fun = "__scawm_river_${toString i}_${toString i'}";
      #     in
      #     ''
      #       ${fun}() { riverctl enter-mode normal; ${action}; }
      #       riverctl map ${v.name} ${mkKeys keys} spawn '${fun}'
      #     ''
      #   ) v.switch
      # ) (filterAttrs (_: v: (isAttrs v) && (hasAttr "switch" v)) modes);
    };
  };
}
