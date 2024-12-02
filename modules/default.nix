{ lib, ... }:
let
  inherit (lib) mkEnableOption mkOption;
  inherit (lib.types)
    str
    attrsOf
    submodule
    oneOf
    ;
  bindOpts = submodule (
    {
      name,
      config,
      options,
      ...
    }:
    {
      # TODO: apply regex to check validity
      apply =
        i:
        assert (name != "") "";
        i;
    }
  );
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
  imports = [ ./river.nix ./sway.nix ./sxhkd.nix ];
  options.scawm = {
    enable = mkEnableOption "Enables ShortCuts for Any Window Manager";
    autoEnable = mkEnableOption "Configures your shortcuts for every available wm / compositor";
    modifier = mkOption {
      type = str;
      description = "Main modifier key";
      default = "Super";
    };
    bindings = mkOption {
      type = attrsOf (oneOf [
        modeOpts
        str
      ]);
      default = { };
      example = {
        "Super Enter" = "kitty";
        "Alt v" = "rofi clipmenu";
        "Ctrl+Shift s" = "flameshot full";
        "Super r" = {
          name = "Run";
          switch = {
            "s" = "spotify";
            "f" = "firefox";
          };
        };
        "Super m" = {
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
