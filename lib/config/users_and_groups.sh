function User() {
    ValidateFunctionParams 1 $# $FUNCNAME

    local user=$@

    shift
    while [[ $# -gt 0 ]]; do
        if [[ $1 =~ --groups=[a-z]+ ]]; then
            shift
        elif [[ $1 =~ --shell=[a-z]+ ]]; then
            shift
        else
            Error "Invalid flag $1 for $FUNCNAME"
        fi
    done

    users+=("$user")
}

function Group() {
    ValidateFunctionParams 1 $# $FUNCNAME

    groups+=($1)
}
