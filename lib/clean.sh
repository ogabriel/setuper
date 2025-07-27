source $lib_dir/helper_functions.sh

DefineDistro

if [[ $distro == "arch" ]]; then
    sudo pacman -Rns --noconfirm $(pacman -Qdtq)
elif [[ $distro == "debian" ]]; then
    sudo apt-get autoremove --purge -y
fi
