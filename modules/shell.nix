{ pkgs }:

rec {
  ansi = import ./ansi.nix;
  colored = ansi.colored;

  /* Creates a shell script with optional zsh-completions and with extra metadata.
   *
   * Example:
   *
   * apps = [ "production" "staging" ];
   *
   * scale-app = hestia.shell.mkShellScript rec {
   *    name = "scale-app";
   *    description = "change the number of running instances of ${colored.white (builtins.elemAt arguments 0)} to ${colored.white (builtins.elemAt arguments 1)}";
   *    arguments = [ "production" "0" ];
   *    content = ''
   *      echo "Scaling $1 to $2"
   *    '';
   *    completionsContent = hestia.completions.directArgs name apps;
   * };
   */
  mkShellScript = { name, content, arguments ? [ ], description ? null, completionsContent ? null }:
    let
      completions =
        if completionsContent != null then
          pkgs.writeText "${name}-completions.zsh" completionsContent
        else
          null;

      installCompletions =
        if completions != null then
          "installShellCompletion --name _${name} --zsh ${completions}"
        else
          "";

      src = pkgs.writeText name content;
    in
    pkgs.stdenv.mkDerivation rec {
      inherit name src arguments;

      dontUnpack = true;

      buildInputs = [ pkgs.buildPackages.installShellFiles ];

      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/${name}
        chmod 0755 $out/bin/${name}

        ${installCompletions}
      '';

      meta = {
        inherit description;
      };
    };

  /* Creates a new shell using given shell scripts and packages.
   *
   * Example: 
   * let
   *   my-ip = hestia.shell.mkShellScript { ... };
   *   scale-app = hestia.shell.mkShellScript { ... };
   * in
   * hestia.shell.mkShell {
   *   name = "project-env";
   * 
   *   shellScripts = [
   *     {
   *       group = "utility";
   *       commands = [
   *         my-ip
   *       ];
   *     }
   *     {
   *       group = "apps";
   *       commands = [
   *         scale-app
   *       ];
   *     }
   *   ];
   * 
   *   packages = [
   *     pkgs.curl
   *     pkgs.jq
   *   ];
   * }
   */
  mkShell = { name, shellScripts ? [ ], packages ? [ ] }:
    let
      commands = shellScripts ++ [{ group = "utility"; commands = [ showCommands ]; }];

      # { "utility" = [ "command 1", "command 2"]; "ci" = [ ] }
      executables =
        let
          # { "utility" = [ { group = "utility", commands = [ "command 1" ] }, { group = "utility", commands = [ "command 2" ] }  ]; "ci" = [ ]; }
          cmds = builtins.groupBy (c: c.group) commands;
          # { "utility" = [ "command 1", "command 2"]; "ci" = [ ]; }
          out = builtins.mapAttrs (g: c: builtins.concatMap (c1: c1.commands) c) cmds;
        in
        out;

      showCommands =
        let
          cmds = pkgs.lib.mapAttrsToList makeGroupSections executables;
        in
        mkShellScript {
          name = "commands";
          description = "show shell-specific commands";
          content = ''
            echo -e "${builtins.concatStringsSep "\n" (builtins.concatLists cmds)}"
          '';
        };
    in
    pkgs.mkShell {
      inherit name;

      shellHook = ''
        echo -e "Welcome to the ${colored.yellow name} shell"
        echo ""
        ${showCommands.name}
      '';

      packages = (builtins.concatLists (pkgs.lib.mapAttrsToList (g: c: c) executables)) ++ packages;
    };

  ## internal 

  makeGroupSections = group: commands: (
    with pkgs.lib; # lists
    with builtins; # stringLength, map, concatLists
    let
      args = entry: if entry ? "arguments" then entry.arguments else [ ];
      entryLength = e: stringLength (e.name) + stringLength (toString (args e));

      maxLine = lists.foldl (max: entry: trivial.max max (entryLength entry)) 0 commands;

      padTo = str: num: if num > 0 then padTo "${str} " (num - 1) else str;

      renderCommand = idx: entry: (
        let
          command = colored.green entry.name;
          argList = map colored.white (args entry);
          pad = padTo " " (maxLine - (entryLength entry));
          desc =
            if entry.meta ? "description" && entry.meta.description != null then
              "${toString pad}- ${entry.meta.description}"
            else
              "";
        in
        "${toString idx}) ${command} ${toString argList}${desc}"
      );

      cmds = lists.imap1 renderCommand commands;
      groupName = [ "# ${colored.yellow "Commands"} [${colored.magenta group}]" ];
      newLine = [ "" ];
    in
    concatLists [ groupName newLine cmds newLine ]
  );
}
