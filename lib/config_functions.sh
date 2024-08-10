source $lib_dir/config/asdf.sh
source $lib_dir/config/packages.sh
source $lib_dir/config/ssh.sh

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
