function HandlePackages() {
    case $distro in
    arch)
        if [[ ${#aur_packages[*]} -gt 0 ]]; then
            local installer=yay
        else
            local installer=pacman
        fi
        ;;
    debian)
        local installer=apt
        ;;
    *)
        Error "Installer not found for distro: $distro"
        ;;
    esac

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
            sudo pacman -Sy --noconfirm --needed archlinux-keyring

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
