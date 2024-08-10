source $lib_dir/config/asdf.sh
source $lib_dir/config/packages.sh
source $lib_dir/config/ssh.sh
source $lib_dir/config/files_and_directories.sh
source $lib_dir/config/systemd.sh
source $lib_dir/config/users_and_groups.sh

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
