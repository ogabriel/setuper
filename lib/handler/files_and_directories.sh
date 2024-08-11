function ParseChmod() {
    local chmod=$1

    chmod=${chmod//\ /}

    echo $chmod_parsed
}

function SystemCreateDirectories() {
    local directories=(${1//\// })
    local current="/"

    for ((i = 0; i + 1 < ${#directories[@]}; i++)); do
        current+="${directories[i]}/"

        if ! sudo test -d $current; then
            sudo mkdir $current
        fi
    done
}

function HandleSystemFile() {
    local from_file=$1
    from_file=${from_file//[[:space:]]/}
    from_file=${from_file%/}
    local to_file=$2
    to_file=${to_file//[[:space:]]/}
    to_file=${to_file%/}
    local chmod=$3

    if ! sudo test -f $to_file; then
        SystemCreateDirectories $to_file
        Info "Copying file $from_file to $to_file"
        sudo cp $from_file $to_file
    else
        if ! sudo diff $from_file $to_file &>/dev/null; then
            Info "Copying file $from_file to $to_file"
            sudo cp $from_file $to_file
        fi
    fi

    if [[ -n $chmod ]]; then
        if [[ "$(sudo stat -c %a $to_file)" != $chmod ]]; then
            Info "Changing permissions of file $to_file to $chmod"
            sudo chmod $chmod $to_file
        fi
    fi
}

function HandleSystemFiles() {
    for ((i = 0; i < ${#system_files[@]}; i++)); do
        local system_file_config
        readarray -d ' ' system_file_config <<<"${system_files[$i]}"

        local from_file=$system_files_dir${system_file_config[0]}
        local to_file=${system_file_config[0]}
        local chmod=${system_file_config[1]#--chmod=}

        HandleSystemFile $from_file $to_file $chmod
    done
}

function HandleSystemFilesFromTo() {
    for ((i = 0; i < ${#system_files_from_to[@]}; i++)); do
        local system_file_config
        readarray -d ' ' system_file_config <<<"${system_files_from_to[$i]}"

        local from_file=$system_files_dir${system_file_config[0]}
        local to_file=${system_file_config[1]}
        local chmod=${system_file_config[2]#--chmod=}

        HandleSystemFile $from_file $to_file $chmod
    done
}

function HandleSystemDirectory() {
    local from_dir=$1
    from_dir=${from_dir//[[:space:]]/}
    from_dir=${from_dir%/}
    local to_dir=$2
    to_dir=${to_dir//[[:space:]]/}
    to_dir=${to_dir%/}
    local chmod=$3

    if ! sudo test -d $to_dir; then
        SystemCreateDirectories $to_dir
        Info "Copying directory $from_dir to $to_dir"
        sudo cp -r $from_dir $to_dir
    else
        if ! sudo diff -r $from_dir $to_dir &>/dev/null; then
            Info "Copying directory $from_dir to $to_dir"
            sudo rm -rf $to_dir
            sudo cp -rf $from_dir $to_dir
        fi
    fi

    if [[ -n $chmod ]]; then
        if [[ "$(sudo stat -c %a $to_dir)" != $chmod ]]; then
            Info "Changing permissions of directory $to_dir to $chmod"
            sudo chmod $chmod $to_dir
        fi
    fi
}

function HandleSystemDirectories() {
    for ((i = 0; i < ${#system_directories[@]}; i++)); do
        local system_directory_config
        readarray -d ' ' system_directory_config <<<"${system_directories[$i]}"

        local from_dir=$system_files_dir${system_directory_config[0]}
        local to_dir=${system_directory_config[0]}
        local chmod=${system_directory_config[1]#--chmod=}

        HandleSystemDirectory $from_dir $to_dir $chmod
    done
}

function HandleSystemDirectoriesFromTo() {
    for ((i = 0; i < ${#system_directories_from_to[@]}; i++)); do
        local system_directory_config
        readarray -d ' ' system_directory_config <<<"${system_directories_from_to[$i]}"

        local from_dir=$system_files_dir${system_directory_config[0]}
        local to_dir=${system_directory_config[1]}
        local chmod=${system_directory_config[2]#--chmod=}

        HandleSystemDirectory $from_dir $to_dir $chmod
    done
}

function UserCreateDirectories() {
    local directories=(${1//\// })
    local current=$HOME/

    for ((i = 0; i + 1 < ${#directories[@]}; i++)); do
        current+="${directories[i]}/"

        if ! test -d $current; then
            Info "Creating directory $current"
            mkdir $current
        fi
    done
}

function HandleUserFile() {
    local from_file=$1
    from_file=${from_file//[[:space:]]/}
    from_file=${from_file%/}
    local to_file=$2
    to_file=${to_file//[[:space:]]/}
    to_file=${to_file%/}
    local home_to_file=$HOME/$to_file

    if ! [[ -L $home_to_file || -f $home_to_file ]]; then
        UserCreateDirectories $to_file
        Info "Linking file $from_file to $home_to_file"
        ln -s $from_file $home_to_file
    elif [[ "$(readlink $home_to_file)" != $from_file ]]; then
        Info "Linking file $from_file to $home_to_file"
        ln -sf $from_file $home_to_file
    fi
}

function HandleUserFiles() {
    for file in ${user_files[*]}; do
        HandleUserFile $user_files_dir$file $file
    done
}

function HandleUserFilesFromTo() {
    for ((i = 0; i < ${#user_files_from_to[@]}; i++)); do
        local user_file_config
        readarray -d ' ' user_file_config <<<"${user_files_from_to[$i]}"

        local from_file=$user_files_dir${user_file_config[0]}
        local to_file=${user_file_config[1]}

        HandleUserFile $from_file $to_file
    done
}

function HandleUserDirectory() {
    local from_dir=$1
    from_dir=${from_dir//[[:space:]]/}
    from_dir=${from_dir%/}
    local to_dir=$2
    to_dir=${to_dir//[[:space:]]/}
    to_dir=${to_dir%/}
    local home_to_dir=$HOME/$to_dir

    if [[ ! -d $home_to_dir ]]; then
        UserCreateDirectories $to_dir
        Info "Linking directory from $from_dir to $to_dir"
        ln -s $from_dir $home_to_dir
    elif [[ "$(readlink $home_to_dir)" != $from_dir ]]; then
        Info "Linking directory from $from_dir to $to_dir"
        rm -rf $home_to_dir
        ln -s $from_dir $home_to_dir
    fi
}

function HandleUserDirectories() {
    for directory in ${user_directories[*]}; do
        HandleUserDirectory $user_files_dir$directory $directory
    done
}

function HandleUserDirectoriesFromTo() {
    for ((i = 0; i < ${#user_directories_from_to[@]}; i++)); do
        local user_directory_config
        readarray -d ' ' user_directory_config <<<"${user_directories_from_to[$i]}"

        local from_dir=$user_files_dir${user_directory_config[0]}
        local to_dir=${user_directory_config[1]}

        HandleUserDirectory $from_dir $to_dir
    done
}
