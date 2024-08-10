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
