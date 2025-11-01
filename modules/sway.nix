{ lib, config, ... }:
let
  inherit (lib)
    optionalAttrs
    nameValuePair
    mapAttrs'
    mapAttrs
    isString
    mkIf
    ;
  inherit (config.scawm)
    integrations
    modifier
    ;
  inherit (import ./lib.nix { inherit lib config; })
    mkIntegration
    topLvlModes
    spcToPlus
    defmode
    modes
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
        // (mapAttrs (_: v: "mode ${v.name}") (spcToPlus (topLvlModes type)));
      modes = mapAttrs' (
        _: v:
        nameValuePair v.name (
          (optionalAttrs (v ? switch) (
            mapAttrs (_: v: if isString v then "mode default, exec ${v}" else "mode ${v.name}") v.switch
          ))
          // (optionalAttrs (v ? stay) (
            mapAttrs (_: v: if isString v then "exec ${v}" else "mode ${v.name}") v.stay
          ))
          // {
            "Escape" = "mode default";
          }
        )
      ) (spcToPlus (modes type));
    };
  };
}
