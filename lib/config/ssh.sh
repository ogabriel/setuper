function SSHGenKey() {
    ValidateFunctionParams 1 $# $FUNCNAME

    local ssh_key=$@

    shift
    while [[ $# -gt 0 ]]; do
        if [[ "$1" =~ --file=.+ ]]; then
            ValidateFileName ${1#--file=}
            shift
        elif [[ "$1" =~ --comment=.+ ]]; then
            shift
        else
            Error "Invalid flag $1 for $FUNCNAME"
        fi
    done

    ssh_gen_keys+=("$ssh_key")
}

function SSHAddKey() {
    ValidateExactFunctionParams 1 $# $FUNCNAME
    ValidateFileName $1

    ssh_add_keys+=($1)
}
