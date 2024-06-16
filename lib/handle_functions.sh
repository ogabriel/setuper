function HandleGroups() {
    for group in ${groups[*]}; do
        if ! getent group $group &>/dev/null; then
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
            sudo useradd $user
        fi

        if [[ ${groups} ]]; then
            for group in ${groups_by_user[$user]}; do
                if ! getent group $group &>/dev/null; then
                    sudo groupadd $group
                fi

                if ! id $user | grep $group &>/dev/null; then
                    sudo usermod -aG $group $user
                fi
            done
        fi

        if [[ $shell ]]; then
            if ! getent passwd $user | cut -d : -f 7 | grep $shell &>/dev/null; then
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

    if [[ ${#packages[*]} -eq 0 ]]; then
        Info "No packages to install"
    else
        sudo pacman -Syy --noconfirm --needed ${packages[*]}

        case $installer in
        pacman)
            sudo pacman -Sy --noconfirm archlinux-keyring
            sudo pacman -Sy --noconfirm --needed ${packages[*]}

            ;;
        yay)
            sudo pacman -Sy --noconfirm archlinux-keyring

            if ! pacman -Q yay &>/dev/null; then
                source $lib_dir/installer/yay.sh
            fi

            yay -Syy --noconfirm --needed ${aur_packages[*]}
            ;;
        esac
    fi
}

function HandleSystemdUnits() {
    echo "systemd"
    if [[ ${#systemd_unit_system_enable[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_user_enable[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_system_mask[*]} -gt 0 ]]; then

        sudo systemctl daemon-reload

        for service in ${systemd_unit_system_enable[*]}; do
            if ! systemctl is-enabled --quiet $sevice &>/dev/null; then
                sudo systemctl enable $service
            fi
        done

        for service in ${systemd_unit_user_enable[*]}; do
            if ! systemctl --user is-enabled --quiet $sevice &>/dev/null; then
                systemctl --user enable $service
            fi
        done

        for service in ${systemd_unit_system_mask[*]}; do
            if ! systemctl list-unit-files --quiet --state=masked | grep $service &>/dev/null; then
                sudo systemctl mask $service
            fi
        done
    fi
}
