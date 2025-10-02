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
  type = "sway";
  cfg = integrations.${type};
in
{
  options.scawm.integrations.${type} = mkIntegration type;
  config = mkIf cfg.enable {
    wayland.windowManager.${type}.config = {
      inherit modifier;
      keybindings =
        (mapAttrs (_: v: "exec ${v}") (spcToPlus (defmode type)))
        // (mapAttrs (_: v: "mode ${v.name}") (spcToPlus (modes type)));
      modes = mapAttrs' (
        _: v:
        nameValuePair v.name (
          (optionalAttrs (v ? switch) (mapAttrs (_: v: "mode default, exec ${v}") v.switch))
          // (optionalAttrs (v ? stay) (mapAttrs (_: v: "exec ${v}") v.stay))
          // {
            "Escape" = "mode default";
          }
        )
      ) (spcToPlus (modes type));
    };
  };
}
