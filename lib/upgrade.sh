source $lib_dir/helper_functions.sh

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

download_file() {
    local url="$1"
    local output="$2"

    if command_exists wget; then
        wget -O "$output" "$url"
    elif command_exists curl; then
        curl -L -o "$output" "$url"
    else
        Error "Neither wget nor curl is available"
    fi
}

file_path="/tmp/"
github_url="https://github.com/ogabriel/setuper/releases/latest/download/"

if command_exists pacman; then
    file="setuper.pkg.tar.zst"

    download_file "$github_url$file" "$file_path$file"
    sudo pacman -U --needed --noconfirm "$file_path$file"

elif command_exists dpkg; then
    file="setuper.deb"

    download_file "$github_url$file" "$file_path$file"
    sudo dpkg -i "$file_path$file"
fi

Info "upgraded successfully!"
