if [[ $# -eq 0 ]]; then
    printf "A simple and complete configuration manager!

Usage:
    Create your config files in ~/.config/setuper/

    More information in the repository: https://github.com/ogabriel/setuper

Options:
    install    Install everything configured in the config files
    "
else
    readonly lib_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    readonly config_dir=${XDG_CONFIG_HOME:-$HOME/.config}/setuper

    case $1 in
    install)
        source $lib_dir/install.sh
        ;;
    *)
        echo "Invalid option"
        ;;
    esac
fi
