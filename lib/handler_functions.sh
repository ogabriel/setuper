source $lib_dir/handler/asdf.sh
source $lib_dir/handler/packages.sh
source $lib_dir/handler/users_and_groups.sh
source $lib_dir/handler/files_and_directories.sh
source $lib_dir/handler/ssh.sh
source $lib_dir/handler/systemd.sh

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
