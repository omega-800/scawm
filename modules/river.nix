{ lib, config, ... }:
let
  inherit (lib)
    pipe
    mkIf
    mapAttrs'
    nameValuePair
    filterAttrs
    concatLines
    hasAttr
    isAttrs
    optionalAttrs
    hasInfix
    imap
    attrsToList
    escape
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
  mkKeys = n: (if (hasInfix " " n) then n else "None ${n}");
  mkSpawn = s: "spawn '${escapeA s}'";
  mapVals = f: a: mapAttrs' (n: v: nameValuePair (mkKeys n) (f v)) a;
  escapeA = s: escape [ "'" ] s;
  concatImapAttrsLines =
    f: a:
    pipe a [
      attrsToList
      (imap (i: v: f i v.name v.value))
      concatLines
    ];
in
{
  options.scawm.integrations.river = mkIntegration "river";
  config = mkIf cfg.enable {
    wayland.windowManager.river = {
      settings = {
        declare-mode = modeNames;
        map =
          {
            normal = (mapVals mkSpawn defmode) // (mapVals (v: "enter-mode ${v.name}") modes);
          }
          // (mapAttrs' (
            _: v:
            nameValuePair v.name (
              (optionalAttrs (v ? stay) (mapVals mkSpawn v.stay))
              // {
                "None Escape" = "enter-mode normal";
              }
            )
          ) modes);
      };
      extraConfig = concatImapAttrsLines (
        i: _: v:
        concatImapAttrsLines (
          i': keys: action:
          let
            fun = "__scawm_river_${toString i}_${toString i'}";
          in
          ''
            ${fun}() { riverctl enter-mode normal; ${action}; }
            riverctl map ${v.name} ${mkKeys keys} spawn '${fun}'
          ''
        ) v.switch
      ) (filterAttrs (_: v: (isAttrs v) && (hasAttr "switch" v)) modes);
    };
  };
}
