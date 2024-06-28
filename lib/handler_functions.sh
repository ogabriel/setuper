function HandleGroups() {
    for group in ${groups[*]}; do
        if ! getent group $group &>/dev/null; then
            Info "Creating group $group"
            sudo groupadd $group
        fi
    done
}

function HandleUsers() {
    for ((i = 0; i < ${#users[@]}; i++)); do
        local user_config
        readarray -d ' ' user_config <<<"${users[$i]}"

        for ((j = 0; j < ${#user_config[@]}; j++)); do
            if [[ ${user_config[j]} =~ --groups=.+ ]]; then
                local groups=${user_config[j]#--groups=}
                groups=${groups//[[:space:]]/}
                groups=(${groups//,/ })
            elif [[ ${user_config[j]} =~ --shell=.+ ]]; then
                local shell=${user_config[j]#--shell=}
                shell=${shell//[[:space:]]/}
            else
                local user=${user_config[j]}
            fi
        done

        if ! id -u $user &>/dev/null; then
            Info "Creating user $user"
            sudo useradd $user
        fi

        if [[ ${groups} ]]; then
            for group in ${groups_by_user[$user]}; do
                if ! getent group $group &>/dev/null; then
                    Info "Creating group $group for user $user"
                    sudo groupadd $group
                fi

                if ! id $user | grep $group &>/dev/null; then
                    Info "Adding user $user to group $group"
                    sudo usermod -aG $group $user
                fi
            done
        fi

        if [[ $shell ]]; then
            if ! getent passwd $user | cut -d : -f 7 | grep $shell &>/dev/null; then
                Info "Changing shell of user $user to $shell"
                sudo usermod -s $(which $shell) $user
            fi
        fi
    done
}

function HandlePackagesRemoval() {
    if [[ ${#packages_to_remove[*]} -gt 0 ]]; then
        case $distro in
        arch)
            Info "Removing packages with pacman"
            sudo pacman -Rns --noconfirm ${packages_to_remove[*]}
            ;;
        debian)
            Info "Removing packages with apt"
            sudo apt-get remove -y ${packages_to_remove[*]}
            ;;
        *)
            Error "Installer not found for distro: $distro"
            ;;
        esac
    fi
}

function HandlePackages() {
    if [[ $distro == 'arch' ]]; then
        if [[ ${#aur_packages[*]} -gt 0 ]]; then
            local installer=yay
        else
            local installer=pacman
        fi
    elif [[ $distro == 'debian' ]]; then
        local installer=apt
    fi

    if [[ ${#packages[*]} -gt 0 ]] ||
        [[ ${#group_packages[*]} -gt 0 ]] ||
        [[ ${#aur_packages[*]} -gt 0 ]]; then

        case $installer in
        pacman)
            Info "Installing packages with pacman"
            sudo pacman -Sy --noconfirm --needed archlinux-keyring
            sudo pacman -S --noconfirm --needed ${packages[*]} ${group_packages[*]}
            ;;
        yay)
            sudo pacman -Sy --noconfirm archlinux-keyring

            if ! pacman -Q yay &>/dev/null; then
                source $lib_dir/installer/yay.sh
            fi

            Info "Installing packages with yay"
            yay -S --noconfirm --needed ${packages[*]} ${group_packages[*]} ${aur_packages[*]}
            ;;
        apt)
            Info "Installing packages with apt"
            sudo apt-get update
            sudo apt-get install -y ${packages[*]}
            ;;
        *)
            Error "Installer not found for distro: $distro"
            ;;
        esac
    fi
}

function HandleSourcedPackages() {
    for ((i = 0; i < ${#sourced_packages[@]}; i++)); do
        local sourced_package_config
        readarray -d ' ' sourced_package_config <<<"${sourced_packages[$i]}"

        local package=${sourced_package_config[0]}
        local file=$sourced_package_dir${sourced_package_config[1]#--source=}

        case $distro in
        arch)
            Info "Installing sourced package $package with pacman"
            sudo pacman -U --noconfirm $file
            ;;
        debian)
            Info "Installing sourced package $package with dpkg"
            sudo dpkg -i $file
            ;;
        *)
            Error "Installer not found for distro: $distro"
            ;;
        esac
    done

}

function HandleFlatpakPackages() {
    if [[ ${#flatpak_packages[*]} -gt 0 ]]; then
        if [[ ${flatpak_is_installed:=$(command -v flatpak &>/dev/null && echo true || echo false)} = false ]]; then
            packages+=('flatpak')

            Info "Flatpak will be installed, restart your computer after setuper runs to install flatpak packages"
        else
            Info "Installing flatpak packages"
            flatpak install --assumeyes --noninteractive flathub ${flatpak_packages[*]}
        fi
    fi
}

function HandlePreInstallASDF() {
    if [[ ${#asdf_plugins[*]} -gt 0 ]]; then
        if [[ ${asdf_is_installed:=$(command -v asdf &>/dev/null && echo true || echo false)} = false ]]; then
            case $distro in
            arch)
                Pkg asdf-vm --AUR
                ;;
            debian)
                Pkg git
                Pkg curl
                ;;
            esac
        fi
    fi
}

function HandlePostInstallASDF() {
    if [[ ${#asdf_plugins[*]} -gt 0 ]]; then
        case $distro in
        debian)
            source $lib_dir/installer/asdf.sh
            ;;
        esac
    fi
}

function HandleASDFPlugins() {
    for plugin in ${asdf_plugins[*]}; do
        Info "Adding ASDF plugin $plugin"
        asdf plugin add $plugin
    done
}

function HandleSystemdUnits() {
    if [[ ${#systemd_unit_system_enable[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_user_enable[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_system_mask[*]} -gt 0 ]]; then

        sudo systemctl daemon-reload

        for service in ${systemd_unit_system_enable[*]}; do
            if ! systemctl is-enabled --quiet $service &>/dev/null; then
                Info "Enabling systemmd system unit $service"
                sudo systemctl enable $service
            fi
        done

        for service in ${systemd_unit_user_enable[*]}; do
            if ! systemctl --user is-enabled --quiet $service &>/dev/null; then
                Info "Enabling systemmd user unit $service"
                systemctl --user enable $service
            fi
        done

        for service in ${systemd_unit_system_mask[*]}; do
            if ! systemctl list-unit-files --quiet --state=masked | grep $service &>/dev/null; then
                Info "Masking systemmd unit $service"
                sudo systemctl mask $service
            fi
        done
    fi
}

function ParseChmod() {
    local chmod=$1

    chmod=${chmod//\ /}

    echo $chmod_parsed
}

function SystemCreateDirectories() {
    local directories=(${1//\// })
    local current="/"

    for ((i = 0; i + 1 < ${#directories[@]}; i++)); do
        current+="${directories[i]}/"

        if ! sudo test -d $current; then
            sudo mkdir $current
        fi
    done
}

function HandleSystemFile() {
    local from_file=$1
    from_file=${from_file//[[:space:]]/}
    from_file=${from_file%/}
    local to_file=$2
    to_file=${to_file//[[:space:]]/}
    to_file=${to_file%/}
    local chmod=$3

    if ! sudo test -f $to_file; then
        SystemCreateDirectories $to_file
        Info "Copying file $from_file to $to_file"
        sudo cp $from_file $to_file
    else
        if ! sudo diff $from_file $to_file &>/dev/null; then
            Info "Copying file $from_file to $to_file"
            sudo cp $from_file $to_file
        fi
    fi

    if [[ -n $chmod ]]; then
        if [[ "$(stat -c %a $to_file)" != $chmod ]]; then
            Info "Changing permissions of file $to_file to $chmod"
            sudo chmod $chmod $to_file
        fi
    fi
}

function HandleSystemFiles() {
    for ((i = 0; i < ${#system_files[@]}; i++)); do
        local system_file_config
        readarray -d ' ' system_file_config <<<"${system_files[$i]}"

        local from_file=$system_files_dir${system_file_config[0]}
        local to_file=${system_file_config[0]}
        local chmod=${system_file_config[1]#--chmod=}

        HandleSystemFile $from_file $to_file $chmod
    done
}

function HandleSystemFilesFromTo() {
    for ((i = 0; i < ${#system_files_from_to[@]}; i++)); do
        local system_file_config
        readarray -d ' ' system_file_config <<<"${system_files_from_to[$i]}"

        local from_file=$system_files_dir${system_file_config[0]}
        local to_file=${system_file_config[1]}
        local chmod=${system_file_config[2]#--chmod=}

        HandleSystemFile $from_file $to_file $chmod
    done
}

function HandleSystemDirectory() {
    local from_dir=$1
    from_dir=${from_dir//[[:space:]]/}
    from_dir=${from_dir%/}
    local to_dir=$2
    to_dir=${to_dir//[[:space:]]/}
    to_dir=${to_dir%/}
    local chmod=$3

    if ! sudo test -d $to_dir; then
        SystemCreateDirectories $to_dir
        Info "Copying directory $from_dir to $to_dir"
        sudo cp -r $from_dir $to_dir
    else
        if ! sudo diff -r $from_dir $to_dir &>/dev/null; then
            Info "Copying directory $from_dir to $to_dir"
            sudo rm -rf $to_dir
            sudo cp -rf $from_dir $to_dir
        fi
    fi

    if [[ -n $chmod ]]; then
        if [[ "$(sudo stat -c %a $to_dir)" != $chmod ]]; then
            Info "Changing permissions of directory $to_dir to $chmod"
            sudo chmod $chmod $to_dir
        fi
    fi
}

function HandleSystemDirectories() {
    for ((i = 0; i < ${#system_directories[@]}; i++)); do
        local system_directory_config
        readarray -d ' ' system_directory_config <<<"${system_directories[$i]}"

        local from_dir=$system_files_dir${system_directory_config[0]}
        local to_dir=${system_directory_config[0]}
        local chmod=${system_directory_config[1]#--chmod=}

        HandleSystemDirectory $from_dir $to_dir $chmod
    done
}

function HandleSystemDirectoriesFromTo() {
    for ((i = 0; i < ${#system_directories_from_to[@]}; i++)); do
        local system_directory_config
        readarray -d ' ' system_directory_config <<<"${system_directories_from_to[$i]}"

        local from_dir=$system_files_dir${system_directory_config[0]}
        local to_dir=${system_directory_config[1]}
        local chmod=${system_directory_config[2]#--chmod=}

        HandleSystemDirectory $from_dir $to_dir $chmod
    done
}

function UserCreateDirectories() {
    local directories=(${1//\// })
    local current=$HOME/

    for ((i = 0; i + 1 < ${#directories[@]}; i++)); do
        current+="${directories[i]}/"

        if ! test -d $current; then
            Info "Creating directory $current"
            mkdir $current
        fi
    done
}

function HandleUserFile() {
    local from_file=$1
    from_file=${from_file//[[:space:]]/}
    from_file=${from_file%/}
    local to_file=$2
    to_file=${to_file//[[:space:]]/}
    to_file=${to_file%/}
    local home_to_file=$HOME/$to_file

    if [[ ! -f $home_to_file ]]; then
        UserCreateDirectories $to_file
        Info "Linking file $from_file to $home_to_file"
        ln -s $from_file $home_to_file
    elif [[ "$(readlink $home_to_file)" != $from_file ]]; then
        Info "Linking file $from_file to $home_to_file"
        ln -sf $from_file $home_to_file
    fi
}

function HandleUserFiles() {
    for file in ${user_files[*]}; do
        HandleUserFile $user_files_dir$file $HOME/$file
    done
}

function HandleUserFilesFromTo() {
    for ((i = 0; i < ${#user_files_from_to[@]}; i++)); do
        local user_file_config
        readarray -d ' ' user_file_config <<<"${user_files_from_to[$i]}"

        local from_file=$user_files_dir${user_file_config[0]}
        local to_file=${user_file_config[1]}

        HandleUserFile $from_file $to_file
    done
}

function HandleUserDirectory() {
    local from_dir=$1
    from_dir=${from_dir//[[:space:]]/}
    from_dir=${from_dir%/}
    local to_dir=$2
    to_dir=${to_dir//[[:space:]]/}
    to_dir=${to_dir%/}
    local home_to_dir=$HOME/$to_dir

    if [[ ! -d $home_to_dir ]]; then
        UserCreateDirectories $to_dir
        Info "Linking directory from $from_dir to $to_dir"
        ln -s $from_dir $home_to_dir
    elif [[ "$(readlink $home_to_dir)" != $from_dir ]]; then
        Info "Linking directory from $from_dir to $to_dir"
        rm -rf $home_to_dir
        ln -s $from_dir $home_to_dir
    fi
}

function HandleUserDirectories() {
    for directory in ${user_directories[*]}; do
        HandleUserDirectory $user_files_dir$directory $directory
    done
}

function HandleUserDirectoriesFromTo() {
    for ((i = 0; i < ${#user_directories_from_to[@]}; i++)); do
        local user_directory_config
        readarray -d ' ' user_directory_config <<<"${user_directories_from_to[$i]}"

        local from_dir=$user_files_dir${user_directory_config[0]}
        local to_dir=${user_directory_config[1]}

        HandleUserDirectory $from_dir $to_dir
    done
}

function HandleSSHGenKeys() {
    for ((i = 0; i < ${#ssh_gen_keys[@]}; i++)); do
        local gen_key_config
        readarray -d ' ' gen_key_config <<<"${ssh_gen_keys[$i]}"

        for ((j = 0; j < ${#gen_key_config[@]}; j++)); do
            if [[ ${gen_key_config[j]} =~ --file=.+ ]]; then
                local file=${gen_key_config[j]#--file=}
                file=${file//[[:space:]]/}
            elif [[ ${gen_key_config[j]} =~ --comment=.+ ]]; then
                local comment=${gen_key_config[j]#--comment=}
                comment=${comment//[[:space:]]/}
            else
                local algo=${gen_key_config[j]}
                algo=${algo//[[:space:]]/}
            fi
        done

        if [[ -n $file ]] && [[ -n $comment ]]; then
            local file_path=$HOME/.ssh/$file

            if ! [[ -f "$file_path" ]]; then
                Info "Generating SSH key $algo"
                ssh-keygen -t $algo -f $file_path -C $comment
            fi
        elif [[ -n $file ]]; then
            if ! [[ -f $HOME/.ssh/$file ]]; then
                Info "Generating SSH key $algo"
                ssh-keygen -t $algo -f $HOME/.ssh/$file
            fi
        elif [[ -n $comment ]]; then
            if ! [[ -f $HOME/.ssh/id_$algo ]]; then
                Info "Generating SSH key $algo"
                ssh-keygen -t $algo -C $comment
            fi
        else
            if ! [[ -f $HOME/.ssh/id_$algo ]]; then
                Info "Generating SSH key $algo"
                ssh-keygen -t $algo
            fi
        fi
    done
}

function HandleSSHAddkeys() {
    for ssh_key in ${ssh_add_keys[*]}; do
        local ssh_public_key_file="$HOME/.ssh/$ssh_key.pub"

        if [[ -f "$ssh_public_key_file" ]]; then
            if ! [[ "$(ssh-add -L)" =~ "$(cat $ssh_public_key_file)" ]]; then
                Info "Adding SSH key $ssh_public_key_file to ssh-agent"
                ssh-add $HOME/.ssh/$ssh_key
            fi
        else
            Error "Invalid SSH key $ssh_public_key_file"
        fi
    done
}
