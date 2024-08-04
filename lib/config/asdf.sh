function ASDFPlugin() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    asdf_plugins+=($1)
}
