{ pkgs ? import ./nix {}
, compilerVersion ? "ghcHEAD"
, doCheck ? false
, lib ? pkgs.lib
, this ? "noupdatethunk"
, inNixShell ? false
}: with lib;
let
  newpkgs = pkgs.extend (self: super: let
    baseHaskellPackages = if compilerVersion == null then super.haskellPackages else super.haskell.packages.${compilerVersion};
  in {
    haskellPackages = baseHaskellPackages.extend (with super.haskell.lib; let
      in  hself: hsuper: {
        "${this}" = (hsuper.callCabal2nix "${this}" ./. {}).overrideAttrs (drv: {
          passthru = drv.passthru or {} // {
            pkgs =  self;
            haskellPackages = hself;
            shell = hsuper.shellFor {
              packages = p: [ p.${this} ];
              buildInputs = [
              #   hself.haskell-language-server
                pkgs.haskellPackages.cabal-install
              ];
            };
          };
        });
      });
  });
  this' = newpkgs.haskellPackages.${this};
in if inNixShell then this'.shell else this'
