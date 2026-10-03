source $lib_dir/helper_functions.sh

DefineDistro

if [[ $distro == "arch" ]]; then
    packages_to_remove=($(pacman -Qdtq))

    if [[ ${#packages_to_remove[*]} -gt 0 ]]; then
        sudo pacman -Rns --noconfirm $packages_to_remove
    fi
elif [[ $distro == "debian" ]]; then
    sudo apt-get autoremove --purge -y
fi
