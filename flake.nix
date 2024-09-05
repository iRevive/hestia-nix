{
  description = "A micro library that helps organizing the local development environment";

  outputs = { self, nixpkgs }: {
    templates.default = {
      path = ./template;
      description = "nix flake new -t 'github:iRevive/hestia-nix' my-new-project/";
      welcomeText = ''
        Happy hacking with hestia-nix!

        Next steps:  
        1) Update flake: `nix flake update`  
        2) Enter the shell via `nix develop`
      '';
    };
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    lib = import ./.;
    overlays.default = import ./overlay.nix;
  };
}
