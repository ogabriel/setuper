error='\033[0;31m'
warn='\033[0;33m'
info='\033[0;32m'
no_color='\033[0m'

function Error() {
    local message=${1:-"ERROR: something went wrong"}
    >&2 echo -e "${error}ERROR: $no_color$message"
    exit 1
}

function Warn() {
    local message=${1:-"WARNING: something went wrong"}
    >&2 echo -e "${warn}WARNING: $no_color$message"
}

function Info() {
    local message=${1:-"INFO: something went wrong"}
    echo -e "${info}INFO: $no_color$message"
}

function CheckConfig() {
    if [[ ! -d $config_dir ]]; then
        Error "Config directory not found in $config_dir"
    fi

    if ! [[ -n "$(find $config_dir -maxdepth 1 -type f -size +0 -iname "*.sh" -print -quit)" ]]; then
        Error "No valid .sh files found in $config_dir"
    fi
}

function CheckPermissons() {
    if ! [[ $EUID -ne 0 ]]; then
        Error "This script must not be run as root nor with sudo"
    fi
}

function DefineDistro() {
    if [[ -f /etc/os-release ]]; then
        distro_id=$(grep -oP '^ID=\K(\w+)' /etc/os-release)
        distro=$(grep -oP '^ID_LIKE=\K(\w+)' /etc/os-release) || echo $distro_id
        distro_version=$(grep -oP '^VERSION_ID=\K(.+)' /etc/os-release)
    else
        Error "No /etc/os-release file found, Could not specify distro"
    fi

}

function ValidateFunctionParams() {
    if [[ $2 -lt $1 ]]; then
        if [[ $1 -eq 1 ]]; then
            Error "At least $1 param is required for $3"
        else
            Error "At least $1 params are required for $3"
        fi
    fi
}

function ValidateExactFunctionParams() {
    if [[ $2 -ne $1 ]]; then
        if [[ $1 -eq 1 ]]; then
            Error "Exactly $1 param is required for $3"
        else
            Error "Exactly $1 params are required for $3"
        fi
    fi
}
