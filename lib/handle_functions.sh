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
                groups=${groups//,/}
                groups=(${groups//,/ })
            elif [[ ${user_config[j]} =~ --shell=.+ ]]; then
                local shell=${user_config[j]#--shell=}
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
    for index in ${!packages_to_remove[*]}; do
        if pacman -Q ${packages_to_remove[index]} &>/dev/null; then
            unset 'packages_to_remove[$index]'
        fi
    done

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
    for index in ${!packages[*]}; do
        if pacman -Q ${packages[index]} &>/dev/null; then
            unset 'packages[$index]'
        fi
    done

    for index in ${!aur_packages[*]}; do
        if pacman -Q ${aur_packages[index]} &>/dev/null; then
            unset 'aur_packages[$index]'
        fi
    done

    for index in ${!group_packages[*]}; do
        if pacman -Qg ${group_packages[index]} &>/dev/null; then
            unset 'group_packages[$index]'
        fi
    done

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
            sudo pacman -Sy --noconfirm archlinux-keyring
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
            if ! pacman -Q $package &>/dev/null; then
                Info "Installing sourced package $package with pacman"
                sudo pacman -Sy --noconfirm archlinux-keyring
                sudo pacman -U --noconfirm $file
            fi
            ;;
        debian)
            if ! dpkg -l $package &>/dev/null; then
                Info "Installing sourced package $package with dpkg"
                sudo dpkg -i $file
            fi
            ;;
        *)
            Error "Installer not found for distro: $distro"
            ;;
        esac
    done

}

function HandleFlatpakPackages() {
    if [[ ${#flatpak_packages[*]} -gt 0 ]]; then
        if ! command -v flatpak; then
            case $distro in
            arch)
                Info "Installing flatpak with pacman"
                sudo pacman -S --noconfirm flatpak
                ;;
            debian)
                Info "Installing flatpak with apt"
                sudo apt-get install -y flatpak
                ;;
            *)
                Error "Installer not found for distro: $distro, could not install flatpak"
                ;;
            esac

            Info "Flatpak installed, restart your computer to install the flatpak packages"
        else
            for ((i = 0; i < ${#flatpak_packages[*]}; i++)); do
                if flatpak list | grep ${flatpak_packages[i]} &>/dev/null; then
                    unset 'flatpak_packages[$i]'
                fi
            done

            if [[ ${#flatpak_packages[*]} -gt 0 ]]; then
                Info "Installing flatpak packages"
                flatpak install --assumeyes --noninteractive flathub ${flatpak_packages[*]}
            fi
        fi
    fi
}

function HandleSystemdUnits() {
    if [[ ${#systemd_unit_system_enable[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_user_enable[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_system_mask[*]} -gt 0 ]]; then

        sudo systemctl daemon-reload

        for service in ${systemd_unit_system_enable[*]}; do
            if ! systemctl is-enabled --quiet $sevice &>/dev/null; then
                Info "Enabling systemmd system unit $service"
                sudo systemctl enable $service
            fi
        done

        for service in ${systemd_unit_user_enable[*]}; do
            if ! systemctl --user is-enabled --quiet $sevice &>/dev/null; then
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
    local to_file=$2
    local chmod=$3

    if ! sudo test -f $to_file; then
        SystemCreateDirectories $to_file
        Info "Copying file $from_file to $to_file"
        sudo cp $from_file $to_file
    else
        if ! sudo diff $from_file $to_file; then
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
    local to_dir=$2
    local chmod=$3

    if ! sudo test -d $to_dir; then
        SystemCreateDirectories $to_dir
        Info "Copying directory $from_dir to $to_dir"
        sudo cp -r $from_dir $to_dir
    else
        if ! sudo diff -r $from_dir $to_dir; then
            Info "Copying directory $from_dir to $to_dir"
            sudo cp -r $from_dir $to_dir
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
    local current="/"

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
    local to_file=$2

    if [[ ! -L $to_file ]] || [[ "$(readlink $to_file)" != $from_file ]]; then
        UserCreateDirectories $to_file
        Info "Linking file $from_file to $to_file"
        ln -s $from_file $to_file
    elif [[ -f $to_file ]]; then
        Info "Linking file $from_file to $to_file"
        ln -sf $from_file $to_file
    fi
}

function HandleUserFiles() {
    for file in ${user_files[*]}; do
        HandleUserFile $user_files_dir$file $HOME$file
    done
}

function HandleUserFilesFromTo() {
    for ((i = 0; i < ${#user_files_from_to[@]}; i += 2)); do
        HandleUserFile $user_files_dir${user_files_from_to[i]} $HOME${user_files_from_to[i + 1]}
    done
}

function HandleUserDirectory() {
    local from_dir=$1
    local to_dir=$2

    if [[ ! -L $to_dir ]] || [[ "$(readlink $to_dir)" != $from_dir ]]; then
        UserCreateDirectories $to_dir
        Info "Linking directory from $from_dir to $to_dir"
        ln -s $from_dir $to_dir
    elif [[ -d $to_dir ]]; then
        Info "Linking directory from $from_dir to $to_dir"
        ln -sf $from_dir $to_dir
    fi
}

function HandleUserDirectories() {
    for directory in ${user_directories[*]}; do
        HandleUserDirectory $user_files_dir$directory $HOME$directory
    done
}

function HandleUserDirectoriesFromTo() {
    for ((i = 0; i < ${#user_directories_from_to[@]}; i += 2)); do
        HandleUserDirectory $user_files_dir${user_directories_from_to[i]} $HOME${user_directories_from_to[i + 1]}
    done
}

function HandleSSHGenKeys() {
    for ((i = 0; i < ${#ssh_gen_keys[@]}; i++)); do
        local gen_key_config
        readarray -d ' ' gen_key_config <<<"${ssh_gen_keys[$i]}"

        for ((j = 0; j < ${#gen_key_config[@]}; j++)); do
            if [[ ${gen_key_config[j]} =~ --file=.+ ]]; then
                local file=${gen_key_config[j]#--file=}
                file=${file//\ /}
            elif [[ ${gen_key_config[j]} =~ --comment=.+ ]]; then
                local comment=${gen_key_config[j]#--comment=}
                comment=${comment//\ /}
            else
                local algo=${gen_key_config[j]}
                algo=${algo//\ /}
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
            Error "Invalid SSH key $$ssh_public_key_file"
        fi
    done
}
