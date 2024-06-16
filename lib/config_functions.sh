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

function SystemdUnitSystemEnable() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_unit_system_enable+=($1)
}

function SystemdUnitUserEnable() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_unit_user_enable+=($1)
}

function SystemdUnitSystemMask() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_unit_system_mask+=($1)
}

system_files_dir=$config_dir/system

function SystemFile() {
    ValidateFunctionParams 1 $# $FUNCNAME

    local from_file=$system_files_dir$1

    if [[ -f $from_file ]]; then
        system_files+=($1)
    else
        Error "Invalid file $from_file"
    fi
}

function SystemFileFromTo() {
    ValidateExactFunctionParams 2 $# $FUNCNAME

    local from_file=$system_files_dir$1

    if [[ -f $from_file ]]; then
        system_files_from_to+=($1 $2)
    else
        Error "Invalid file $from_file"
    fi
}

function SystemDirectory() {
    ValidateFunctionParams 1 $# $FUNCNAME

    local from_dir=$system_files_dir$1

    if [[ -d $from_dir ]]; then
        system_directories+=($1)
    else
        Error "Invalid directory $from_dir"
    fi
}

function SystemDirectoryFromTo() {
    ValidateExactFunctionParams 2 $# $FUNCNAME

    local from_dir=$system_files_dir$1

    if [[ -d $from_dir ]]; then
        system_directories_from_to+=("$1 $2")
    else
        Error "Invalid directory $from_dir"
    fi
}

user_files_dir=$config_dir/user

function UserFile() {
    ValidateFunctionParams 1 $# $FUNCNAME

    local from_file=$user_files_dir$1

    if [[ -f $from_file ]]; then
        user_files+=($1)
    else
        Error "Invalid file $from_file"
    fi
}

function UserFileFromTo() {
    ValidateExactFunctionParams 2 $# $FUNCNAME

    local from_file=$user_files_dir$1

    if [[ -f $from_file ]]; then
        user_files_from_to+=($1 $2)
    else
        Error "Invalid file $from_file"
    fi
}

function UserDirectory() {
    ValidateFunctionParams 1 $# $FUNCNAME

    local from_directory=$user_files_dir$1

    if [[ -d $from_directory ]]; then
        user_directories+=($1)
    else
        Error "Invalid directory $from_directory"
    fi
}

function UserDirectoryFromTo() {
    ValidateExactFunctionParams 2 $# $FUNCNAME

    local from_directory=$user_files_dir$1

    if [[ -d $from_directory ]]; then
        user_directories_from_to+=("$1 $2")
    else
        Error "Invalid directory $from_directory"
    fi
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
