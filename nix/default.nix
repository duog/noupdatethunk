with builtins;
{ sources ? import ./sources.nix
, config ? {}
, overlays ? []
, system ? currentSystem
}: let
  head-hackage-overlay = self: super:
    import ./head.hackage {
      haskellOverrides = hself: hsuper: {
        hscolour = with self.haskell.lib; overrideSrc hsuper.hscolour {
          src = ../hscolour-1.24.4;
        };
      };
    } self super;
in import sources.nixpkgs {
  inherit config system;
  overlays = overlays ++ [head-hackage-overlay];
}
