function HandlePackages() {
    if [[ $distro == "arch" &&
        (${#packages[*]} -gt 0 || ${#group_packages[*]} -gt 0 || ${#aur_packages[*]} -gt 0) ]]; then
        __HandleArchPackages
    elif [[ $distro == "debian" && ${#packages[*]} -gt 0 ]]; then
        __HandleDebianPackages
    fi
}

function __HandleArchPackages() {
    __HandleArchPackagesCleanUp
    __HandleArchPackagesRemoval
    __HandleArchPackagesInstallation
}

function __HandleArchPackagesCleanUp() {
    local unused_packages=($(pacman -Qdtq))

    if [[ ${#unused_packages[*]} -gt 0 ]]; then
        Info "Removing unused dependencies: ${unused_packages[*]}"
        Info "Proceed with removal? [Y/n]"
        read -n 1 key
        echo

        if [[ $key == "Y" ]]; then
            sudo pacman -Rns --noconfirm ${unused_packages[*]}
        else
            Info "Unused dependencies not removed"
        fi
    else
        Info "No unused dependencies to remove"
    fi
}

function __HandleArchPackagesRemoval() {
    local installed_packages=($(pacman -Qteq))
    readarray -t installed_group_packages <<<"$(pacman -Qtg)"

    for installed_package in ${installed_packages[*]}; do
        if [[ $installed_package != "setuper" ]] &&
            [[ $installed_package != "yay" ]] &&
            [[ $installed_package != "yay-bin" ]] &&
            [[ $installed_package != "pacman" ]] &&
            [[ $installed_package != "base" ]] &&
            __InstalledPackageNotInPackages? $installed_package &&
            __InstalledPackageNotInAurPackages? $installed_package &&
            __InstalledPackageNotInAurPackages? $installed_package &&
            __InstalledPackageNotInSourcedPackages? $installed_package &&
            __InstalledPackageNotInGroupPackages? $installed_package; then
            packages_to_remove+=($installed_package)
        fi
    done

    if [[ ${#packages_to_remove[*]} -gt 0 ]]; then
        Info "Removing packages outside configuration: ${packages_to_remove[*]}"
        Info "Proceed with removal? [Y/n]"
        read -n 1 key
        echo

        if [[ $key == "Y" ]]; then
            sudo pacman -Rns --noconfirm ${packages_to_remove[*]}
        else
            Info "Packages outside configuration not removed"
        fi
    else
        Info "No packages to remove"
    fi
}

function __InstalledPackageNotInPackages?() {
    for package in ${packages[*]}; do
        if [[ $package = $1 ]]; then
            return 1
        fi
    done

    return 0
}

function __InstalledPackageNotInAurPackages?() {
    for package in ${aur_packages[*]}; do
        if [[ $package = $1 ]]; then
            return 1
        fi
    done

    return 0
}

function __InstalledPackageNotInSourcedPackages?() {
    for ((i = 0; i < ${#sourced_packages[@]}; i++)); do
        local sourced_package_config
        readarray -d ' ' sourced_package_config <<<"${sourced_packages[$i]}"

        local package=${sourced_package_config[0]}
        package=${package//[[:space:]]/}

        if [[ $package == $1 ]]; then
            return 1
        fi
    done

    return 0
}

function __InstalledPackageNotInGroupPackages?() {
    for group in ${group_packages[*]}; do
        for ((i = 0; i < ${#installed_group_packages[@]}; i++)); do
            local installed_group_package_config
            readarray -d ' ' installed_group_package_config <<<"${installed_group_packages[$i]}"

            local installed_group=${installed_group_package_config[0]}
            local installed_group_package=${installed_group_package_config[1]}

            installed_group=${installed_group//[[:space:]]/}
            installed_group_package=${installed_group_package//[[:space:]]/}

            if [[ $installed_group == $group ]]; then
                if [[ $installed_group_package == $1 ]]; then
                    return 1
                fi
            fi
        done
    done

    return 0
}

function __HandleArchPackagesInstallation() {
    local packages_to_install=()

    for package in ${packages[*]}; do
        if ! pacman -Qq $package &>/dev/null; then
            packages_to_install+=($package)
        fi
    done

    for package in ${group_packages[*]}; do
        local group_packages=($(pacman -Sgq $package))

        for group_package in ${group_packages[*]}; do
            if ! pacman -Qq $group_package &>/dev/null; then
                packages_to_install+=($group_package)
            fi
        done
    done

    for package in ${aur_packages[*]}; do
        if ! pacman -Qq $package &>/dev/null; then
            packages_to_install+=($package)
        fi
    done

    if [[ ${#packages_to_install[*]} -gt 0 ]]; then
        Info "Installing packages from configuration: ${packages_to_install[*]}"
        Info "Proceed with installation? [Y/n]"
        read -n 1 key
        echo

        if [[ $key == "Y" ]]; then
            if [[ ${#aur_packages[*]} -gt 0 ]]; then
                local installer=yay
            else
                local installer=pacman
            fi

            sudo pacman -Sy --noconfirm --needed archlinux-keyring

            case $installer in
            pacman)
                Info "Installing packages with pacman"
                sudo pacman -S --noconfirm --needed ${packages[*]} ${group_packages[*]}
                ;;
            yay)

                if ! pacman -Q yay &>/dev/null; then
                    source $lib_dir/installer/yay.sh
                fi

                Info "Installing packages with yay"
                yay -S --noconfirm --needed ${packages[*]} ${group_packages[*]} ${aur_packages[*]}
                ;;
            esac
        else
            Info "Packages from configuration not installed"
        fi
    else
        Info "No packages from configuration to install"
    fi
}

function __HandleDebianPackages() {
    Info "Installing packages with apt"
    sudo apt-get update
    sudo apt-get install -y ${packages[*]}
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
