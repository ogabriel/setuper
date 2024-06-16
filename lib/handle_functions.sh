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
        echo ${users[$i]}
        readarray -d ' ' user_config <<<"${users[$i]}"

        for ((j = 0; j < ${#user_config[@]}; j++)); do
            if [[ ${user_config[j]} =~ --groups=.+ ]]; then
                local groups=${user_config[j]#--groups=}
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

    if ! [[ ${#aur_packages[*]} -eq 0 ]]; then
        packages+=(${aur_packages[*]})

        local installer=yay
    else
        local installer=pacman
    fi

    if ! [[ ${#packages[*]} -eq 0 ]]; then
        case $installer in
        pacman)
            Info "Installing packages with pacman"
            sudo pacman -Sy --noconfirm archlinux-keyring
            sudo pacman -S --noconfirm --needed ${packages[*]}

            ;;
        yay)
            sudo pacman -Sy --noconfirm archlinux-keyring

            if ! pacman -Q yay &>/dev/null; then
                source $lib_dir/installer/yay.sh
            fi

            Info "Installing packages with yay"
            yay -S --noconfirm --needed ${aur_packages[*]}
            ;;
        esac
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
}

function HandleSystemFiles() {
    for to_file in ${system_files[*]}; do
        HandleSystemFile $system_files_dir$to_file $to_file
    done
}

function HandleSystemFilesFromTo() {
    for ((i = 0; i < ${#system_files_from_to[@]}; i += 2)); do
        HandleSystemFile $system_files_dir${system_files_from_to[i]} ${system_files_from_to[i + 1]}
    done
}

function HandleSystemDirectory() {
    local from_dir=$1
    local to_dir=$2

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
}

function HandleSystemDirectories() {
    for to_dir in ${system_directories[*]}; do
        HandleSystemDirectory $system_files_dir$to_dir $to_dir
    done
}

function HandleSystemDirectoriesFromTo() {
    for ((i = 0; i < ${#system_directories_from_to[@]}; i += 2)); do
        HandleSystemDirectory $system_files_dir${system_directories_from_to[i]} ${system_directories_from_to[i + 1]}
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
