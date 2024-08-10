function RemovePkg() {
    RemovePackage $@
}

function RemovePackage() {
    ValidateFunctionParams 1 $# $FUNCNAME

    case $distro in
    arch)
        if pacman -Q $1 &>/dev/null; then
            packages_to_remove+=($1)
        fi
        ;;
    debian)
        if dpkg -l $1 &>/dev/null; then
            packages_to_remove+=($1)
        fi
        ;;
    *)
        Error "Could not check if package $1 is installed on $distro"
        ;;
    esac
}

function Pkg() {
    Package $@
}

function Package() {
    if [[ $# -eq 1 ]]; then
        case $distro in
        arch)
            if ! pacman -Q $1 &>/dev/null; then
                packages+=($1)
            fi
            ;;
        debian)
            if ! dpkg -l $1 &>/dev/null; then
                packages+=($1)
            fi
            ;;
        *)
            Error "Could not check if package $1 is installed on $distro"
            ;;
        esac
    elif [[ $2 == '--aur' ]] || [[ $2 == '--AUR' ]]; then
        ValidateExactFunctionParams 2 $# $FUNCNAME

        if [[ $distro == 'arch' ]]; then
            if ! pacman -Q $1 &>/dev/null; then
                aur_packages+=($1)
            fi
        else
            Error "AUR packages are only supported on Arch Linux"
        fi
    elif [[ $2 == '--group' ]]; then
        ValidateExactFunctionParams 2 $# $FUNCNAME

        if [[ $distro == 'arch' ]]; then
            if ! pacman -Qg $1 &>/dev/null; then
                group_packages+=($1)
            fi
        else
            Error "Group packages are only supported on Arch Linux"
        fi
    elif [[ $2 =~ --source=.* ]]; then
        ValidateExactFunctionParams 2 $# $FUNCNAME

        local file=$sourced_package_dir${2#--source=}

        if [[ -f $file ]]; then
            case $distro in
            arch)
                if ! pacman -Q $1 &>/dev/null; then
                    sourced_packages+=("$1 $2")
                fi
                ;;
            debian)
                if ! dpkg -l $1 &>/dev/null; then
                    sourced_packages+=("$1 $2")
                fi
                ;;
            *)
                Error "Could not check if package $1 is installed on $distro"
                ;;
            esac
        else
            Error "Invalid package source file $file"
        fi
    elif [[ $2 == '--flatpak' ]]; then
        ValidateExactFunctionParams 2 $# $FUNCNAME

        if [[ ${flatpak_is_installed:=$(command -v flatpak &>/dev/null && echo true || echo false)} = true ]]; then
            if ! flatpak list | grep $1 &>/dev/null; then
                flatpak_packages+=($1)
            fi
        else
            flatpak_packages+=($1)
        fi
    else
        Error "Invalid flag $2 for $FUNCNAME"
    fi
}
