{ lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) submodule str attrsOf;
in
{
  options.scawm.wm = mkOption {
    default = {
      sxhkd = {
        "super" = "super";
        "ctrl" = "ctrl";
        "alt" = "alt";
        "shift" = "shift";
        "space" = "space";
        "bspc" = "BackSpace";
        "delete" = "Delete";
        "tab" = "Tab";
        "return" = "Return";
        "right" = "Right";
        "left" = "Left";
        "up" = "Up";
        "down" = "Down";
      };
    };
    type = attrsOf (submodule {
      options = {
        "enter" = mkOption {
          type = str;
          default = "enter";
        };
        "super" = mkOption {
          type = str;
          default = "super";
        };
        "ctrl" = mkOption {
          type = str;
          default = "ctrl";
        };
        "alt" = mkOption {
          type = str;
          default = "alt";
        };
        "shift" = mkOption {
          type = str;
          default = "shift";
        };
        "space" = mkOption {
          type = str;
          default = "space";
        };
        "bspc" = mkOption {
          type = str;
          default = "bspc";
        };
        "del" = mkOption {
          type = str;
          default = "del";
        };
        "tab" = mkOption {
          type = str;
          default = "tab";
        };
        "right" = mkOption {
          type = str;
          default = "right";
        };
        "left" = mkOption {
          type = str;
          default = "left";
        };
        "up" = mkOption {
          type = str;
          default = "up";
        };
        "down" = mkOption {
          type = str;
          default = "down";
        };
      };
    });
  };
}
