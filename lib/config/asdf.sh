function ASDFPlugin() {
    ValidateFunctionParams 1 $# $FUNCNAME

    asdf_plugins+=($1)

    if [[ $# -gt 1 ]]; then
        asdf_plugins_config+=("$1 $2 $3")
    fi
}
