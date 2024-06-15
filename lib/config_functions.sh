#!/bin/bash

function User() {
    ValidateFunctionParams 1 $# $FUNCNAME

    local user=$@

    shift
    while [[ $# -gt 0 ]]; do
        if [[ $1 =~ --groups=.+ ]]; then
            shift
        elif [[ $1 =~ --shell=.+ ]]; then
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

function Package() {
    ValidateFunctionParams 1 $# $FUNCNAME

    if [[ $2 == '--aur' ]] || [[ $2 == '--AUR' ]]; then
        ValidateExactFunctionParams 2 $# $FUNCNAME

        aur_packages+=($1)
    else
        packages+=($1)
    fi
}

function Pkg() {
    Package $@
}

function SystemdEnable() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_enable_system+=($1)
}

function SystemdEnableUser() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_enable_user+=($1)
}

function SystemdMask() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_mask_system+=($1)
}

function SystemFile() {
    ValidateFunctionParams 1 $# $FUNCNAME

    system_files+=($1)
}

function SystemFileFromTo() {
    ValidateExactFunctionParams 2 $# $FUNCNAME

    system_files_from_to+=("$1 $2")
}

function UserFile() {
    ValidateFunctionParams 1 $# $FUNCNAME

    user_files+=($1)
}

function UserFileFromTo() {
    ValidateExactFunctionParams 2 $# $FUNCNAME

    user_files_from_to+=("$1 $2")
}

function SSHGenKey() {
    ValidateFunctionParams 1 $# $FUNCNAME

    local ssh_key=$@

    shift
    while [[ $# -gt 0 ]]; do
        if [[ "$1" =~ --file=.+ ]]; then
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

    ssh_add_keys+=("$ssh_key")
}

function LoadConfig() {
    for file in $config_dir/*.sh; do
        Info "Loading $file"
        source $file
    done
}
