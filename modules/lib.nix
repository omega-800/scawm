{ lib, config, ... }:
let
  inherit (lib)
    filterAttrs
    mapAttrsToList
    mapAttrs'
    nameValuePair
    types
    mkOption
    recursiveUpdate
    concatMapAttrs
    optionalAttrs
    ;
  inherit (types)
    submodule
    str
    attrsOf
    bool
    lazyAttrsOf
    oneOf
    ;
  inherit (builtins) isAttrs isString replaceStrings;
  inherit (config.scawm)
    autoEnable
    ;
  bindingsCfg = wm: recursiveUpdate config.scawm.bindings config.scawm.integrations.${wm}.bindings;
  modeOpts = submodule (_: {
    options = {
      name = mkOption {
        type = str;
        default = "";
        description = "Name of mode";
      };
      switch = mkOption {
        type = lazyAttrsOf (oneOf [
          str
          modeOpts
        ]);
        default = { };
        description = "Keybindings valid for this mode. Will switch back to default mode once activated";
      };
      stay = mkOption {
        type = lazyAttrsOf (oneOf [
          str
          modeOpts
        ]);
        default = { };
        description = "Keybindings valid for this mode. Will stay in this mode after activation";
      };
    };
  });
in
rec {
  bindings = mkOption {
    description = "Keyboard shorcuts live here";
    type = lazyAttrsOf (oneOf [
      # what the actual fuck. the order of these types matters.
      # if modeOpts is first then nix interprets a string with
      # an interpolated path as a module and tries to import it
      str
      modeOpts
    ]);
    default = { };
    example = {
      "Mod4 Enter" = "kitty";
      "Alt v" = "rofi clipmenu";
      "Ctrl+Shift s" = "flameshot full";
      "Mod4 r" = {
        name = "Run";
        switch = {
          "s" = "spotify";
          "f" = "firefox";
        };
      };
      "Mod4 m" = {
        name = "Music";
        stay = {
          "n" = "playerctl next";
          "p" = "playerctl previous";
          "r" = "playerctl volume +10";
          "l" = "playerctl volume -10";
        };
        switch."s" = "playerctl stop";
      };
    };
  };
  inherit bindingsCfg;
  mkIntegration = wm: {
    inherit bindings;
    enable = mkOption {
      description = "Enables shortcuts for ${wm}";
      type = bool;
      default = autoEnable;
    };
  };

  modesRec =
    a:
    concatMapAttrs (
      n: v:
      optionalAttrs ((isAttrs v) && (v ? name)) (
        {
          "${n}" = v;
        }
        // (optionalAttrs (v ? switch) modesRec v.switch)
        // (optionalAttrs (v ? stay) modesRec v.stay)
      )
    ) a;
  modes = wm: modesRec (bindingsCfg wm);

  topLvlModes = wm: filterAttrs (_: v: (isAttrs v) && (v ? name)) (bindingsCfg wm);
  modeNames = wm: mapAttrsToList (_: v: v.name) (modes wm);
  defmode = wm: filterAttrs (_: isString) (bindingsCfg wm);
  mapAttrNamesRec =
    fn: a: mapAttrs' (n: v: nameValuePair (fn n) (if (isAttrs v) then (spcToPlus v) else v)) a;
  spcToPlus = kb: mapAttrNamesRec (replaceStrings [ " " ] [ "+" ]) kb;
  topLvlBinds = filterAttrs (_: isString);
  modeBinds = filterAttrs (_: v: !(isString v));
}
