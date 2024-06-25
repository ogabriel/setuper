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

function RemovePackage() {
    ValidateFunctionParams 1 $# $FUNCNAME

    case $distro in
    'arch')
        if [[ pacman -Q $1 &>/dev/null ]]; then
            packages_to_remove+=($1)
        fi
        ;;
    'debian')
        if [[ dpkg -l $1 &>/dev/null ]]; then
            packages_to_remove+=($1)
        fi
        ;;
    *)
        Error "Could not check if package $1 is installed on $distro"
        ;;
    esac
}

function RemovePkg() {
    RemovePackage $@
}

sourced_packages_dir=$config_dir/packages

function Package() {
    ValidateFunctionParams 1 $# $FUNCNAME

    if [[ $2 == '--aur' ]] || [[ $2 == '--AUR' ]]; then
        ValidateExactFunctionParams 2 $# $FUNCNAME

        if [[ $distro == 'arch' ]]; then
            aur_packages+=($1)
        else
            Error "AUR packages are only supported on Arch Linux"
        fi
    elif [[ $2 == '--group' ]]; then
        ValidateExactFunctionParams 2 $# $FUNCNAME

        if [[ $distro == 'arch' ]]; then
            group_packages+=($1)
        else
            Error "Group packages are only supported on Arch Linux"
        fi
    elif [[ $2 =~ --source=.* ]]; then
        ValidateExactFunctionParams 2 $# $FUNCNAME

        local sourced_file=$sourced_packages_dir$2

        if [[ -f $sourced_file ]]; then
            sourced_packages+=($1)
        else
            Error "Invalid package source file $sourced_file"
        fi
    elif [[ $2 == '--flatpak' ]]; then
        ValidateExactFunctionParams 2 $# $FUNCNAME

        flatpak_packages+=($1)
    else
        packages+=($1)
    fi
}

function Pkg() {
    Package $@
}

function ASDFPlugin() {
    ValidateFunctionParams 1 $# $FUNCNAME

    asdf_plugins+=($1)
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

    local file=$@
    local from_file=$system_files_dir$1

    if [[ -f $from_file ]]; then
        shift
        while [[ $# -gt 0 ]]; do
            if [[ $1 =~ --chmod=\d{3} ]]; then
                shift
            else
                Error "Invalid flag $1 for $FUNCNAME"
            fi
        done

        system_files+=("$file")
    else
        Error "Invalid file $from_file"
    fi
}

function SystemFileFromTo() {
    ValidateExactFunctionParams 2 $# $FUNCNAME

    local file=$@
    local from_file=$system_files_dir$1

    if [[ -f $from_file ]]; then
        shift
        while [[ $# -gt 0 ]]; do
            if [[ $1 =~ --chmod=\d{3} ]]; then
                shift
            else
                Error "Invalid flag $1 for $FUNCNAME"
            fi
        done

        system_files_from_to+=("$file")
    else
        Error "Invalid file $from_file"
    fi
}

function SystemDirectory() {
    ValidateFunctionParams 1 $# $FUNCNAME

    local dir=$@
    local from_dir=$system_files_dir$1

    if [[ -d $from_dir ]]; then
        shift
        while [[ $# -gt 0 ]]; do
            if [[ $1 =~ --chmod=\d{3} ]]; then
                shift
            else
                Error "Invalid flag $1 for $FUNCNAME"
            fi
        done

        system_directories+=("$dir")
    else
        Error "Invalid directory $from_dir"
    fi
}

function SystemDirectoryFromTo() {
    ValidateExactFunctionParams 2 $# $FUNCNAME

    local dir=$@
    local from_dir=$system_files_dir$1

    if [[ -d $from_dir ]]; then
        shift
        while [[ $# -gt 0 ]]; do
            if [[ $1 =~ --chmod=\d{3} ]]; then
                shift
            else
                Error "Invalid flag $1 for $FUNCNAME"
            fi
        done

        system_directories_from_to+=("$dir")
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

    ssh_add_keys+=($1)
}

function LoadConfig() {
    for file in $config_dir/*.sh; do
        Info "Loading $file"
        source $file
    done
}
