{
  /* Creates zsh-compatible completions for the 1st argument of the function.
   *
   * Examples:
   * directArgs "my-script" [ "arg1" "arg2" "arg3" ]
   */
  directArgs = name: args: ''
    #compdef ${name}

    function _${name}() {
      local curcontext="$curcontext" state line
      typeset -A opt_args

      _arguments '1: :->csi'

      case $state in
        csi)
          _arguments "1: :(${toString args})"
        ;;
      esac
    }

    _${name} "$@"
  '';
}
