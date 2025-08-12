source $lib_dir/config/asdf.sh
source $lib_dir/config/packages.sh
source $lib_dir/config/ssh.sh
source $lib_dir/config/systemd.sh
source $lib_dir/config/files_and_directories.sh
source $lib_dir/config/users_and_groups.sh

function LoadConfig() {
    if [[ -f $config_dir/init.sh ]]; then
        Info "Loading init"
        source $config_dir/init.sh
    fi

    : ${config_files_dir:=$config_dir/config}
    : ${system_files_dir:=$config_dir/system/}
    : ${user_files_dir:=$config_dir/user/}
    : ${sourced_package_dir:=$config_dir/packages/}

    CheckConfig

    for file in $config_files_dir/*.sh; do
        Info "Loading $file"
        source $file
    done
}
