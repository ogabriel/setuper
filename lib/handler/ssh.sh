function HandleSSHGenKeys() {
    for ((i = 0; i < ${#ssh_gen_keys[@]}; i++)); do
        local gen_key_config
        readarray -d ' ' gen_key_config <<<"${ssh_gen_keys[$i]}"

        for ((j = 0; j < ${#gen_key_config[@]}; j++)); do
            if [[ ${gen_key_config[j]} =~ --file=.+ ]]; then
                local file=${gen_key_config[j]#--file=}
                file=${file//[[:space:]]/}
            elif [[ ${gen_key_config[j]} =~ --comment=.+ ]]; then
                local comment=${gen_key_config[j]#--comment=}
                comment=${comment//[[:space:]]/}
            else
                local algo=${gen_key_config[j]}
                algo=${algo//[[:space:]]/}
            fi
        done

        if [[ -n $file ]] && [[ -n $comment ]]; then
            local file_path=$HOME/.ssh/$file

            if ! [[ -f "$file_path" ]]; then
                Info "Generating SSH key $algo"
                ssh-keygen -t $algo -f $file_path -C $comment
            fi
        elif [[ -n $file ]]; then
            if ! [[ -f $HOME/.ssh/$file ]]; then
                Info "Generating SSH key $algo"
                ssh-keygen -t $algo -f $HOME/.ssh/$file
            fi
        elif [[ -n $comment ]]; then
            if ! [[ -f $HOME/.ssh/id_$algo ]]; then
                Info "Generating SSH key $algo"
                ssh-keygen -t $algo -C $comment
            fi
        else
            if ! [[ -f $HOME/.ssh/id_$algo ]]; then
                Info "Generating SSH key $algo"
                ssh-keygen -t $algo
            fi
        fi
    done
}

function HandleSSHAddkeys() {
    for ssh_key in ${ssh_add_keys[*]}; do
        local ssh_public_key_file="$HOME/.ssh/$ssh_key.pub"

        if [[ -f "$ssh_public_key_file" ]]; then
            if ! [[ "$(ssh-add -L)" =~ "$(cat $ssh_public_key_file)" ]]; then
                Info "Adding SSH key $ssh_public_key_file to ssh-agent"
                ssh-add $HOME/.ssh/$ssh_key
            fi
        else
            Error "Invalid SSH key $ssh_public_key_file"
        fi
    done
}
