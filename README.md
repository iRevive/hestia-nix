# hestia-nix

Hestia is a micro-library that helps with organizing a local development environment.
The software is unstable and may change drastically over time.  

## Synposis

I've been using [devshell](https://github.com/numtide/devshell) for a while, but it does not satisfy me in several use cases:
- For whatever reason it does not work well with zsh: shell hooks are not executed, MOTD is missing, and so on
- I need to have various project-specific scripts in a shell to simplify daily tasks. I want to have an extended MOTD with examples (i.e. default arguments, etc)
- Shell script utilities: basic autocompletion, detailed description with default arguments

Well, it's a great way to learn nix and flakes. Why should I miss such an opportunity?

## Quick start

You can start with a template:
```shell
$ nix flake new -t 'github:iRevive/hestia-nix' my-new-project/ # create a project from the template
$ cd my-new-project 
$ nix flake update # update dependencies
$ nix develop # enter the shell. (or nix-shell). Autocompletion works only with nix-shell :(
```

## Full example

`flake.nix`:
```nix
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
```

`env-shell.nix`:
```nix
{ pkgs }:

let
  hestia = pkgs.hestia;
  colored = hestia.ansi.colored;

  # utility

  my-ip = hestia.shell.mkShellScript {
    name = "my-ip";
    description = "show detailed information about your IP";
    content = ''
      curl -s --request GET --url https://ipapi.co/json/ | jq .
    '';
  };

  # apps

  apps = [ "production" "staging" ];

  scale-app = hestia.shell.mkShellScript rec {
     name = "scale-app";
     description = "change the number of running instances of ${colored.white (builtins.elemAt arguments 0)} to ${colored.white (builtins.elemAt arguments 1)}";
     arguments = [ "production" "0" ];
     content = ''
       echo "Scaling $1 to $2"
     '';
     completionsContent = hestia.completions.directArgs name apps;
  };

in
hestia.shell.mkShell {
  name = "project-env";

  shellScripts = [
    {
      group = "utility";
      commands = [
        my-ip
      ];
    }
    {
      group = "apps";
      commands = [
        scale-app
      ];
    }
  ];

  packages = [
    pkgs.curl
    pkgs.jq
  ];

  buildInputs = [
    pkgs.s2n-tls
  ];
}
```

Shell welcome message:
```
Welcome to the project-env shell

# Commands [apps]

1) scale-app production 0 - change the number of running instances of production to 0

# Commands [utility]

1) my-ip     - show detailed information about your IP
2) commands  - show shell-specific commands
```
