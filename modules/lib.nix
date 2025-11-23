{ lib, config, ... }:
let
  inherit (lib)
    recursiveUpdate
    mapAttrsToList
    concatMapAttrs
    optionalAttrs
    nameValuePair
    filterAttrs
    mapAttrs'
    mkOption
    types
    ;
  inherit (types)
    lazyAttrsOf
    submodule
    oneOf
    bool
    str
    ;
  inherit (builtins) replaceStrings isString isAttrs;
  inherit (config.scawm) autoEnable;

  bindingsCfg = wm: recursiveUpdate config.scawm.bindings config.scawm.integrations.${wm}.bindings;
  kbOpt =
    description: example:
    mkOption {
      inherit description example;
      type = lazyAttrsOf (oneOf [
        str
        modeOpts
      ]);
      default = { };
    };
  modeOpts = submodule (
    _:
    let
    in
    {
      options = {
        name = mkOption {
          type = str;
          default = "";
          description = "Name of mode";
        };
        switch =
          kbOpt "Keybindings valid for this mode. Will switch back to default mode once activated"
            { };
        stay = kbOpt "Keybindings valid for this mode. Will stay in this mode after activation" { };
      };
    }
  );
  bindings = kbOpt "Keyboard shortcuts live here" {
    "Mod4 Enter" = "kitty";
    "Alt v" = "rofi clipmenu";
    "Ctrl+Shift s" = "flameshot full";
    "Mod4 m" = {
      name = "Music";
      stay = {
        n = "playerctl next";
        p = "playerctl previous";
        r = "playerctl volume +10";
        l = "playerctl volume -10";
      };
      switch.s = "playerctl stop";
    };
  };
  modesRec = concatMapAttrs (
    n: v:
    optionalAttrs ((isAttrs v) && (v ? name)) (
      {
        "${n}" = v;
      }
      // (optionalAttrs (v ? switch) modesRec v.switch)
      // (optionalAttrs (v ? stay) modesRec v.stay)
    )
  );
  spcToPlus = mapAttrNamesRec (replaceStrings [ " " ] [ "+" ]);
  mapAttrNamesRec =
    fn: mapAttrs' (n: v: nameValuePair (fn n) (if (isAttrs v) then (spcToPlus v) else v));
  modes = wm: modesRec (bindingsCfg wm);
in
{
  inherit
    mapAttrNamesRec
    bindingsCfg
    spcToPlus
    bindings
    modesRec
    modes
    ;

  mkIntegration = wm: {
    inherit bindings;
    enable = mkOption {
      description = "Enables shortcuts for ${wm}";
      type = bool;
      default = autoEnable;
    };
  };

  defmode = wm: filterAttrs (_: isString) (bindingsCfg wm);
  modeNames = wm: mapAttrsToList (_: v: v.name) (modes wm);
  modeBinds = filterAttrs (_: v: !(isString v));
  topLvlModes = wm: filterAttrs (_: v: (isAttrs v) && (v ? name)) (bindingsCfg wm);
  topLvlBinds = filterAttrs (_: isString);
}
