{ lib, ... }:
let
  inherit (lib) mkEnableOption mkOption;
  inherit (lib.types)
    str
    attrsOf
    lazyAttrsOf
    submodule
    oneOf
    ;
  modeOpts = submodule (
    {
      name,
      config,
      options,
      ...
    }:
    {
      options = {
        name = mkOption {
          type = str;
          default = "";
          description = "Name of mode";
        };
        switch = mkOption {
          type = attrsOf str;
          default = { };
          description = "Keybindings valid for this mode. Will switch back to default mode once activated";
        };
        stay = mkOption {
          type = attrsOf str;
          default = { };
          description = "Keybindings valid for this mode. Will stay in this mode after activation";
        };
      };
    }
  );
in
{
  imports = [
    ./river.nix
    ./sway.nix
    ./sxhkd.nix
  ];
  options.scawm = {
    enable = mkEnableOption "Enables ShortCuts for Any Window Manager";
    autoEnable = mkEnableOption "Configures your shortcuts for every available wm / compositor";
    modifier = mkOption {
      type = str;
      description = "Main modifier key";
      default = "Mod4";
    };
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
  };
}
