{
  description = "Environment organized with hestia";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/22.05";
    hestia.url = "github:iRevive/hestia-nix";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, hestia, ... }:
    flake-utils.lib.simpleFlake {
      inherit self nixpkgs;
      name = "env";
      overlay = hestia.overlays.default;
      shell = ./env-shell.nix;
    };
}
