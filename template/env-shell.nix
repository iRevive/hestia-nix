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
}
