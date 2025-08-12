if [[ $# -eq 0 ]]; then
    printf "A simple and complete configuration manager!

Usage:
    Create your config files in ~/.config/setuper/

    More information in the repository: https://github.com/ogabriel/setuper

Options:
    apply   Apply the configuration from ~/.config/setuper/
    clean   Clean unused packages
    "
else
    readonly lib_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    readonly config_dir=${XDG_CONFIG_HOME:-$HOME/.config}/setuper
    readonly config_files_dir=$config_dir/config

    case $1 in
    install)
        echo "DEPRECATED: Use 'apply' instead of 'install'."
        source $lib_dir/apply.sh
        ;;
    apply)
        source $lib_dir/apply.sh
        ;;
    clean)
        source $lib_dir/clean.sh
        ;;
    upgrade)
        source $lib_dir/upgrade.sh
        ;;
    *)
        echo "Invalid option"
        ;;
    esac
fi
