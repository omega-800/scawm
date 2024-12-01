{ lib, config, ... }:
let
  inherit (lib)
    mkIf
    mapAttrs'
    nameValuePair
    mapAttrs
    optionalAttrs
    ;
  inherit (config.scawm)
    integrations
    modifier
    ;
  inherit (import ./lib.nix { inherit lib config; })
    modes
    defmode
    mkIntegration
    spcToPlus
    ;
  cfg = integrations.sway;
in
{
  options.scawm.integrations.sway = mkIntegration "sway";
  config = mkIf cfg.enable {
    wayland.windowManager.sway.config = {
      inherit modifier;
      keybindings = (spcToPlus defmode) // (mapAttrs (_: v: "mode ${v.name}") (spcToPlus modes));
      modes = mapAttrs' (
        _: v:
        nameValuePair v.name (
          (optionalAttrs (v ? switch) (mapAttrs (_: v: "mode default, ${v}") v.switch))
          // (v.stay or { })
          // {
            "Escape" = "mode default";
          }
        )
      ) (spcToPlus modes);
    };
  };
}