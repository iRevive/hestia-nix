{
  colored =
    let
      reset = "\\033[0m";
      withColor = color: input: "${color}${input}${reset}";
    in
    {
      yellow = withColor "\\033[0;33m";
      red = withColor "\\033[0;31m";
      green = withColor "\\033[0;32m";
      blue = withColor "\\033[0;34m";
      magenta = withColor "\\033[0;35m";
      cyan = withColor "\\033[0;36m";
      white = withColor "\\033[0;37m";
    };
}
