{ pkgs }:

let
  ansi = import ./modules/ansi.nix;
  completions = import ./modules/completions.nix;
  shell_ = import ./modules/shell.nix { inherit pkgs; };

  shell = {
    mkShellScript = shell_.mkShellScript;
    mkShell = shell_.mkShell;
  };

  lib = {
    inherit
      ansi
      completions
      shell
      ;
  };
in
lib
