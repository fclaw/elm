{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-22.11.tar.gz") {}
, nodejs ? pkgs."nodejs-18_x"
 }:
  pkgs.mkShell {
    buildInputs = [
      pkgs.elmPackages.elm
      nodejs ];}