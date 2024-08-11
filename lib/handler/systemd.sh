function HandleSystemdUnits() {
    if [[ ${#systemd_unit_system_enable[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_system_mask[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_system_disable[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_user_enable[*]} -gt 0 ]]; then

        if ! __AllUnitsFound?; then
            sudo systemctl daemon-reload
        fi

        __HandleSystemEnable
        __HandleSystemMask
        __HandleSystemDisable
        __HandleUserEnable
    fi
}

function __HandleSystemEnable() {
    for service in ${systemd_unit_system_enable[*]}; do
        if ! systemctl is-enabled --quiet $service &>/dev/null; then
            Info "Enabling systemmd system unit $service"
            sudo systemctl enable $service --force
        fi
    done
}

function __HandleSystemMask() {
    for service in ${systemd_unit_system_mask[*]}; do
        if ! systemctl list-unit-files --quiet --state=masked $service &>/dev/null; then
            Info "Masking systemmd unit $service"
            sudo systemctl mask $service
        fi
    done
}

function __HandleSystemDisable() {
    for service in ${systemd_unit_system_disable[*]}; do
        if systemctl list-unit-files --quiet $service &>/dev/null &&
            ! systemctl list-unit-files --quiet --state=disabled $service &>/dev/null; then
            Info "Disabling systemmd system unit $service"
            sudo systemctl disable $service
        fi
    done
}

function __HandleUserEnable() {
    for service in ${systemd_unit_user_enable[*]}; do
        if ! systemctl --user is-enabled --quiet $service &>/dev/null; then
            Info "Enabling systemmd user unit $service"
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

    for service in ${systemd_unit_system_mask[*]}; do
        if ! systemctl list-unit-files --quiet $service &>/dev/null; then
            return 1
        fi
    done

    for service in ${systemd_unit_user_enable[*]}; do
        if ! systemctl --user list-unit-files --quiet $service &>/dev/null; then
            return 1
        fi
    done

    return 0
}
