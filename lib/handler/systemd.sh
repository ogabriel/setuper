function HandleSystemdUnits() {
    local cache_dir="$config_dir/.cache"
    mkdir -p "$cache_dir"

    __ReverseRemovedUnits "$cache_dir"

    if [[ ${#systemd_unit_system_enable[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_system_mask[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_system_unmask[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_system_disable[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_user_enable[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_user_unmask[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_user_disable[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_user_mask[*]} -gt 0 ]]; then

        if ! __AllUnitsFound?; then
            sudo systemctl daemon-reload
        fi

        __WarnConflicts

        __HandleSystemMask
        __HandleSystemUnmask

        __HandleSystemDisable
        __HandleSystemEnable

        __HandleUserMask
        __HandleUserUnmask

        __HandleUserDisable
        __HandleUserEnable
    fi

    __WriteSystemdCache "$cache_dir"
}

function __HandleSystemMask() {
    for service in ${systemd_unit_system_mask[*]}; do
        if ! systemctl list-unit-files --quiet --state=masked $service &>/dev/null; then
            Info "Masking systemd system unit $service"
            sudo systemctl mask $service
        fi
    done
}

function __HandleSystemUnmask() {
    for service in ${systemd_unit_system_unmask[*]}; do
        __HandleSystemUnmaskService $service
    done
}

function __HandleSystemUnmaskService() {
    local service=$1

    if systemctl list-unit-files --quiet --state=masked $service &>/dev/null; then
        Info "Unmasking systemd system unit $service"
        sudo systemctl unmask $service
    fi
}

function __HandleSystemDisable() {
    for service in ${systemd_unit_system_disable[*]}; do
        if systemctl list-unit-files --quiet $service &>/dev/null &&
            ! systemctl list-unit-files --quiet --state=disabled $service &>/dev/null; then
            Info "Disabling systemd system unit $service"
            sudo systemctl disable $service
        fi
    done
}

function __HandleSystemEnable() {
    for service in ${systemd_unit_system_enable[*]}; do
        __HandleSystemUnmaskService $service

        if ! systemctl is-enabled --quiet $service &>/dev/null; then
            Info "Enabling systemd system unit $service"
            sudo systemctl enable $service --force
        fi
    done
}

function __HandleUserUnmask() {
    for service in ${systemd_unit_user_unmask[*]}; do
        __HandleUserUnmaskService $service
    done
}

function __HandleUserUnmaskService() {
    local service=$1

    if systemctl --user list-unit-files --quiet --state=masked $service &>/dev/null; then
        Info "Unmasking systemd user unit $service"
        systemctl --user unmask $service
    fi
}

function __HandleUserMask() {
    for service in ${systemd_unit_user_mask[*]}; do
        if ! systemctl --user list-unit-files --quiet --state=masked $service &>/dev/null; then
            Info "Masking systemd user unit $service"
            systemctl --user mask $service
        fi
    done
}

function __HandleUserDisable() {
    for service in ${systemd_unit_user_disable[*]}; do
        if systemctl --user list-unit-files --quiet $service &>/dev/null &&
            ! systemctl --user list-unit-files --quiet --state=disabled $service &>/dev/null; then
            Info "Disabling systemd user unit $service"
            systemctl --user disable $service
        fi
    done
}

function __HandleUserEnable() {
    for service in ${systemd_unit_user_enable[*]}; do
        __HandleUserUnmaskService $service

        if ! systemctl --user is-enabled --quiet $service &>/dev/null; then
            Info "Enabling systemd user unit $service"
            systemctl --user enable $service
        fi
    done
}

function __AllUnitsFound?() {
    for service in ${systemd_unit_system_enable[*]}; do
        if ! systemctl list-unit-files --quiet $service &>/dev/null; then
            return 1
        fi
    done

    for service in ${systemd_unit_system_disable[*]}; do
        if ! systemctl list-unit-files --quiet $service &>/dev/null; then
            return 1
        fi
    done

    for service in ${systemd_unit_system_mask[*]}; do
        if ! systemctl list-unit-files --quiet $service &>/dev/null; then
            return 1
        fi
    done

    for service in ${systemd_unit_system_unmask[*]}; do
        if ! systemctl list-unit-files --quiet $service &>/dev/null; then
            return 1
        fi
    done

    for service in ${systemd_unit_user_enable[*]}; do
        if ! systemctl --user list-unit-files --quiet $service &>/dev/null; then
            return 1
        fi
    done

    for service in ${systemd_unit_user_disable[*]}; do
        if ! systemctl --user list-unit-files --quiet $service &>/dev/null; then
            return 1
        fi
    done

    for service in ${systemd_unit_user_mask[*]}; do
        if ! systemctl --user list-unit-files --quiet $service &>/dev/null; then
            return 1
        fi
    done

    for service in ${systemd_unit_user_unmask[*]}; do
        if ! systemctl --user list-unit-files --quiet $service &>/dev/null; then
            return 1
        fi
    done

    return 0
}

function __WarnConflicts() {
    for enable_service in ${systemd_unit_system_enable[*]}; do
        for mask_service in ${systemd_unit_system_mask[*]}; do
            if [[ $enable_service == $mask_service ]]; then
                Warn "System unit $enable_service present in both enable and mask lists; will end up enabled"
            fi
        done
    done

    for enable_service in ${systemd_unit_user_enable[*]}; do
        for mask_service in ${systemd_unit_user_mask[*]}; do
            if [[ $enable_service == $mask_service ]]; then
                Warn "User unit $enable_service present in both enable and mask lists; will end up enabled"
            fi
        done
    done
}

function __ReverseRemovedUnits() {
    local cache_dir=$1

    __ReverseFromCache "$cache_dir/systemd_unit_system_enable"  systemd_unit_system_enable  "sudo systemctl disable"
    __ReverseFromCache "$cache_dir/systemd_unit_system_disable" systemd_unit_system_disable "sudo systemctl enable"
    __ReverseFromCache "$cache_dir/systemd_unit_system_mask"    systemd_unit_system_mask    "sudo systemctl unmask"
    __ReverseFromCache "$cache_dir/systemd_unit_system_unmask"  systemd_unit_system_unmask  "sudo systemctl mask"
    __ReverseFromCache "$cache_dir/systemd_unit_user_enable"    systemd_unit_user_enable    "systemctl --user disable"
    __ReverseFromCache "$cache_dir/systemd_unit_user_disable"   systemd_unit_user_disable   "systemctl --user enable"
    __ReverseFromCache "$cache_dir/systemd_unit_user_mask"      systemd_unit_user_mask      "systemctl --user unmask"
    __ReverseFromCache "$cache_dir/systemd_unit_user_unmask"    systemd_unit_user_unmask    "systemctl --user mask"
}

function __ReverseFromCache() {
    local cache_file=$1
    local -n __arr=$2
    local reverse_cmd=$3

    [[ -f $cache_file ]] || return 0

    while IFS= read -r unit; do
        [[ -z $unit ]] && continue
        local found=false
        for item in "${__arr[@]}"; do
            [[ $item == "$unit" ]] && found=true && break
        done
        if [[ $found == false ]]; then
            Info "Cache: running '$reverse_cmd $unit' (unit removed from config)"
            $reverse_cmd "$unit"
        fi
    done < "$cache_file"
}

function __WriteSystemdCache() {
    local cache_dir=$1

    printf '%s\n' "${systemd_unit_system_enable[@]}"  > "$cache_dir/systemd_unit_system_enable"
    printf '%s\n' "${systemd_unit_system_disable[@]}" > "$cache_dir/systemd_unit_system_disable"
    printf '%s\n' "${systemd_unit_system_mask[@]}"    > "$cache_dir/systemd_unit_system_mask"
    printf '%s\n' "${systemd_unit_system_unmask[@]}"  > "$cache_dir/systemd_unit_system_unmask"
    printf '%s\n' "${systemd_unit_user_enable[@]}"    > "$cache_dir/systemd_unit_user_enable"
    printf '%s\n' "${systemd_unit_user_disable[@]}"   > "$cache_dir/systemd_unit_user_disable"
    printf '%s\n' "${systemd_unit_user_mask[@]}"      > "$cache_dir/systemd_unit_user_mask"
    printf '%s\n' "${systemd_unit_user_unmask[@]}"    > "$cache_dir/systemd_unit_user_unmask"
}
