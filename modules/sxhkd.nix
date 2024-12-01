{ lib, config, ... }:
let
  inherit (lib)
    mkIf
    mapAttrs'
    nameValuePair
    concatMapAttrs
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
    spcToPlus
    ;
  cfg = integrations.sxhkd;
in
{
  options.scawm.integrations.sxhkd = mkIntegration "sxhkd";
  config = mkIf cfg.enable {
    services.sxhkd.keybindings =
      (spcToPlus defmode)
      // (concatMapAttrs (
        n: v:
        (optionalAttrs (v ? switch) (mapAttrs' (n': v': nameValuePair "${n} ; ${n'}" v') v.switch))
        // (optionalAttrs (v ? stay) (mapAttrs' (n': v': nameValuePair "${n} : ${n'}" v') v.stay))
      ) (spcToPlus modes));
  };
}
