function HandleSystemdUnits() {
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
