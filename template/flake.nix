{
  description = "Environment organized with hestia";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    hestia.url = "github:iRevive/hestia-nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, hestia, ... }:
    flake-utils.lib.simpleFlake {
      inherit self nixpkgs;
      name = "env";
      overlay = hestia.overlays.default;
      shell = ./env-shell.nix;
    };
}
