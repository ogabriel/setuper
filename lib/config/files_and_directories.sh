function SystemFile() {
    ValidateFunctionParams 1 $# $FUNCNAME

    local file=$@
    local from_file=$system_files_dir$1
    local live_file=$1

    if [[ ! -f $from_file ]]; then
        if sudo test -f "$live_file"; then
            Info "Bootstrapping $live_file → $from_file"
            mkdir -p "$(dirname "$from_file")"
            sudo cp "$live_file" "$from_file"
            sudo chown "$USER" "$from_file"
        else
            Error "Invalid file $from_file"
        fi
    fi

    shift
    while [[ $# -gt 0 ]]; do
        if [[ $1 =~ --chmod=[0-9]{3} ]]; then
            shift
        else
            Error "Invalid flag $1 for $FUNCNAME"
        fi
    done

    system_files+=("$file")
}

function SystemFileFromTo() {
    ValidateFunctionParams 2 $# $FUNCNAME

    local file=$@
    local from_file=$system_files_dir$1
    local live_file=$2

    if [[ ! -f $from_file ]]; then
        if sudo test -f "$live_file"; then
            Info "Bootstrapping $live_file → $from_file"
            mkdir -p "$(dirname "$from_file")"
            sudo cp "$live_file" "$from_file"
            sudo chown "$USER" "$from_file"
        else
            Error "Invalid file $from_file"
        fi
    fi

    shift
    shift
    while [[ $# -gt 0 ]]; do
        if [[ $1 =~ --chmod=[0-9]{3} ]]; then
            shift
        else
            Error "Invalid flag $1 for $FUNCNAME"
        fi
    done

    system_files_from_to+=("$file")
}

function SystemDirectory() {
    ValidateFunctionParams 1 $# $FUNCNAME

    local dir=$@
    local from_dir=$system_files_dir$1
    local live_dir=$1

    if [[ ! -d $from_dir ]]; then
        if sudo test -d "$live_dir"; then
            Info "Bootstrapping $live_dir → $from_dir"
            mkdir -p "$from_dir"
            sudo cp -r "$live_dir/." "$from_dir"
            sudo chown -R "$USER" "$from_dir"
        else
            Error "Invalid directory $from_dir"
        fi
    fi

    shift
    while [[ $# -gt 0 ]]; do
        if [[ $1 =~ --chmod=[0-9]{3} ]]; then
            shift
        else
            Error "Invalid flag $1 for $FUNCNAME"
        fi
    done

    system_directories+=("$dir")
}

function SystemDirectoryFromTo() {
    ValidateFunctionParams 2 $# $FUNCNAME

    local dir=$@
    local from_dir=$system_files_dir$1
    local live_dir=$2

    if [[ ! -d $from_dir ]]; then
        if sudo test -d "$live_dir"; then
            Info "Bootstrapping $live_dir → $from_dir"
            mkdir -p "$from_dir"
            sudo cp -r "$live_dir/." "$from_dir"
            sudo chown -R "$USER" "$from_dir"
        else
            Error "Invalid directory $from_dir"
        fi
    fi

    shift
    shift
    while [[ $# -gt 0 ]]; do
        if [[ $1 =~ --chmod=[0-9]{3} ]]; then
            shift
        else
            Error "Invalid flag $1 for $FUNCNAME"
        fi
    done

    system_directories_from_to+=("$dir")
}

function UserFile() {
    ValidateFunctionParams 1 $# $FUNCNAME
    ValidateFileName $1

    local from_file=$user_files_dir$1
    local live_file=$HOME/$1

    if [[ ! -f $from_file ]]; then
        if [[ -f $live_file ]]; then
            Info "Bootstrapping $live_file → $from_file"
            mkdir -p "$(dirname "$from_file")"
            cp "$live_file" "$from_file"
        else
            Error "Invalid file $from_file"
        fi
    fi

    user_files+=($1)
}

function UserFileFromTo() {
    ValidateExactFunctionParams 2 $# $FUNCNAME
    ValidateFileName $1

    local from_file=$user_files_dir$1
    local live_file=$2

    if [[ ! -f $from_file ]]; then
        if [[ -f $live_file ]]; then
            Info "Bootstrapping $live_file → $from_file"
            mkdir -p "$(dirname "$from_file")"
            cp "$live_file" "$from_file"
        else
            Error "Invalid file $from_file"
        fi
    fi

    user_files_from_to+=("$1 $2")
}

function UserDirectory() {
    ValidateFunctionParams 1 $# $FUNCNAME
    ValidateFileName $1

    local from_directory=$user_files_dir$1
    local live_directory=$HOME/$1

    if [[ ! -d $from_directory ]]; then
        if [[ -d $live_directory ]]; then
            Info "Bootstrapping $live_directory → $from_directory"
            mkdir -p "$from_directory"
            cp -r "$live_directory/." "$from_directory"
        else
            Error "Invalid directory $from_directory"
        fi
    fi

    user_directories+=($1)
}

function UserDirectoryFromTo() {
    ValidateExactFunctionParams 2 $# $FUNCNAME
    ValidateFileName $1

    local from_directory=$user_files_dir$1
    local live_directory=$2

    if [[ ! -d $from_directory ]]; then
        if [[ -d $live_directory ]]; then
            Info "Bootstrapping $live_directory → $from_directory"
            mkdir -p "$from_directory"
            cp -r "$live_directory/." "$from_directory"
        else
            Error "Invalid directory $from_directory"
        fi
    fi

    user_directories_from_to+=("$1 $2")
}
