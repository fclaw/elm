{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-22.11.tar.gz") {}
, nodejs ? pkgs."nodejs-18_x"
 }
  pkgs.mkShell {
    buildInputs = [
      pkgs.elmPackages.elm
      nodejs
      new_spago
      easy-ps.purs-0_15_7
      easy-ps.psc-package
      easy-ps.purescript-language-server
      easy-ps.purs-backend-es ];}