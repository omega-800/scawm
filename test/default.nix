{ config, pkgs, ... }:
let
  inherit (config.scawm) modifier;
in
{
  scawm = {
    enable = true;
    autoEnable = true;
    modifier = "Mod4";
    bindings = {
      "${modifier} Enter" = "kitty";
      "Alt v" = "rofi clipmenu";
      "Ctrl+Shift s" = "flameshot full";
      "${modifier} y" = "${pkgs.screenkey}/bin/screenkey";
      "${modifier} r" = {
        name = "Run";
        switch = {
          s = "spotify";
          f = "firefox";
          r = {
            name = "Run rofi";
            switch = {
              p = "rofi-pass";
              d = "rofi-dmenu";
              b = "rofi-bluetooth";
            };
          };
        };
      };
      "${modifier} m" = {
        name = "Music";
        stay = {
          n = "playerctl next";
          p = "playerctl previous";
          r = "playerctl volume +10";
          l = "playerctl volume -10";
          s = {
            name = "Sinks";
            switch = {
              o = "rofi-pulse-select sink";
              i = "rofi-pulse-select source";
            };
          };
        };
        switch.x = "playerctl stop";
      };
    };
    integrations.sxhkd.bindings = {
      "${modifier}+Shift r" = ''pkill -usr1 -x sxhkd; notify-send 'sxhkd' 'Reloaded config' -t 500'';
      "${modifier} + x" = "slock";
    };
  };
  home = {
    username = "alice";
    homeDirectory = "/home/alice";
    stateVersion = "24.11";
  };
  services.sxhkd.enable = true;
}
