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
    ;
  inherit (import ./lib.nix { inherit lib config; })
    modes
    defmode
    modeNames
    mkIntegration
    ;
  cfg = integrations.river;
in
{
  options.scawm.integrations.river = mkIntegration "river";
  config = mkIf cfg.enable {
    wayland.windowManager.river.settings = {
      declare-mode = modeNames;
      map =
        {
          normal = defmode // (mapAttrs (_: v: "enter-mode ${v.name}") modes);
        }
        // (mapAttrs' (
          _: v:
          nameValuePair v.name (
            (optionalAttrs (v ? switch) (mapAttrs (_: v: "enter-mode normal && ${v}") v.switch))
            // (v.stay or { })
            // {
              "None Escape" = "enter-mode normal";
            }
          )
        ) modes);
    };
  };
}
