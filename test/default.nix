{ config, pkgs, ... }:
let
  inherit (config.scawm) modifier;
in
{
  scawm = {
    enable = true;
    autoEnable = true;
    bindings = {
      "${modifier} Enter" = "kitty";
      "Alt v" = "rofi clipmenu";
      "Ctrl+Shift s" = "flameshot full";
      "${modifier} y" = "${pkgs.screenkey}/bin/screenkey";
      "${modifier} r" = {
        name = "Run";
        switch = {
          "s" = "spotify";
          "f" = "firefox";
          "r" = {
            name = "Run rofi";
            switch = {
              "p" = "rofi-pass";
              "d" = "rofi-dmenu";
              "b" = "rofi-bluetooth";
            };
          };
        };
      };
      "${modifier} m" = {
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
  home = {
    username = "alice";
    homeDirectory = "/home/alice";
    stateVersion = "24.11";
  };
  services.sxhkd.enable = true;
}
