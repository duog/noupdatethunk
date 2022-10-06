with builtins;
{ sources ? import ./sources.nix
, config ? {}
, overlays ? []
, system ? currentSystem
}: let
  # Note this is my branch
#   head-hackage-overlay = import sources.headhackage {};
in import sources.nixpkgs {
  inherit config system overlays;
  # overlays = overlays ++ [head-hackage-overlay];
}
