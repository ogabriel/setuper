source $lib_dir/config/adsf.sh

function LoadConfig() {
    if [[ -f $config_dir/config.sh ]]; then
        Info "Loading config"
        source $config_dir/config.sh
    fi

    : ${system_files_dir:=$config_dir/system/}
    : ${user_files_dir:=$config_dir/user/}
    : ${sourced_package_dir:=$config_dir/packages/}

    for file in $config_dir/*.sh; do
        if [[ $file == $config_dir/config.sh ]]; then
            continue
        else
            Info "Loading $file"
            source $file
        fi
    done
}

function LoadConfigFile() {
    local file=$config_dir\/$1

    Info "Loading $file"
    source $file
}

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

function RemovePackage() {
    ValidateFunctionParams 1 $# $FUNCNAME

    case $distro in
    arch)
        if pacman -Q $1 &>/dev/null; then
            packages_to_remove+=($1)
        fi
        ;;
    debian)
        if dpkg -l $1 &>/dev/null; then
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

function Package() {
    if [[ $# -eq 1 ]]; then
        case $distro in
        arch)
            if ! pacman -Q $1 &>/dev/null; then
                packages+=($1)
            fi
            ;;
        debian)
            if ! dpkg -l $1 &>/dev/null; then
                packages+=($1)
            fi
            ;;
        *)
            Error "Could not check if package $1 is installed on $distro"
            ;;
        esac
    elif [[ $2 == '--aur' ]] || [[ $2 == '--AUR' ]]; then
        ValidateExactFunctionParams 2 $# $FUNCNAME

        if [[ $distro == 'arch' ]]; then
            if ! pacman -Q $1 &>/dev/null; then
                aur_packages+=($1)
            fi
        else
            Error "AUR packages are only supported on Arch Linux"
        fi
    elif [[ $2 == '--group' ]]; then
        ValidateExactFunctionParams 2 $# $FUNCNAME

        if [[ $distro == 'arch' ]]; then
            if ! pacman -Qg $1 &>/dev/null; then
                group_packages+=($1)
            fi
        else
            Error "Group packages are only supported on Arch Linux"
        fi
    elif [[ $2 =~ --source=.* ]]; then
        ValidateExactFunctionParams 2 $# $FUNCNAME

        local file=$sourced_package_dir${2#--source=}

        if [[ -f $file ]]; then
            case $distro in
            arch)
                if ! pacman -Q $1 &>/dev/null; then
                    sourced_packages+=("$1 $2")
                fi
                ;;
            debian)
                if ! dpkg -l $1 &>/dev/null; then
                    sourced_packages+=("$1 $2")
                fi
                ;;
            *)
                Error "Could not check if package $1 is installed on $distro"
                ;;
            esac
        else
            Error "Invalid package source file $file"
        fi
    elif [[ $2 == '--flatpak' ]]; then
        ValidateExactFunctionParams 2 $# $FUNCNAME

        if [[ ${flatpak_is_installed:=$(command -v flatpak &>/dev/null && echo true || echo false)} = true ]]; then
            if ! flatpak list | grep $1 &>/dev/null; then
                flatpak_packages+=($1)
            fi
        else
            flatpak_packages+=($1)
        fi
    else
        Error "Invalid flag $2 for $FUNCNAME"
    fi
}

function Pkg() {
    Package $@
}

function SystemdUnitSystemEnable() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_unit_system_enable+=($1)
}

function SystemdUnitSystemDisable() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_unit_system_disable+=($1)
}

function SystemdUnitUserEnable() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_unit_user_enable+=($1)
}

function SystemdUnitSystemMask() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_unit_system_mask+=($1)
}

function SystemFile() {
    ValidateFunctionParams 1 $# $FUNCNAME

    local file=$@
    local from_file=$system_files_dir$1

    if [[ -f $from_file ]]; then
        shift
        while [[ $# -gt 0 ]]; do
            if [[ $1 =~ --chmod=[0-9]{3} ]]; then
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
    ValidateFunctionParams 2 $# $FUNCNAME

    local file=$@
    local from_file=$system_files_dir$1

    if [[ -f $from_file ]]; then
        shift
        shift
        while [[ $# -gt 0 ]]; do
            if [[ $1 =~ --chmod=[0-9]{3} ]]; then
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
            if [[ $1 =~ --chmod=[0-9]{3} ]]; then
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
    ValidateFunctionParams 2 $# $FUNCNAME

    local dir=$@
    local from_dir=$system_files_dir$1

    if [[ -d $from_dir ]]; then
        shift
        shift
        while [[ $# -gt 0 ]]; do
            if [[ $1 =~ --chmod=[0-9]{3} ]]; then
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

function UserFile() {
    ValidateFunctionParams 1 $# $FUNCNAME
    ValidateFileName $1

    local from_file=$user_files_dir$1

    if [[ -f $from_file ]]; then
        user_files+=($1)
    else
        Error "Invalid file $from_file"
    fi
}

function UserFileFromTo() {
    ValidateExactFunctionParams 2 $# $FUNCNAME
    ValidateFileName $1

    local from_file=$user_files_dir$1

    if [[ -f $from_file ]]; then
        user_files_from_to+=("$1 $2")
    else
        Error "Invalid file $from_file"
    fi
}

function UserDirectory() {
    ValidateFunctionParams 1 $# $FUNCNAME
    ValidateFileName $1

    local from_directory=$user_files_dir$1

    if [[ -d $from_directory ]]; then
        user_directories+=($1)
    else
        Error "Invalid directory $from_directory"
    fi
}

function UserDirectoryFromTo() {
    ValidateExactFunctionParams 2 $# $FUNCNAME
    ValidateFileName $1

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
