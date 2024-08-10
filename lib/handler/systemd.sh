function HandleSystemdUnits() {
    if [[ ${#systemd_unit_system_enable[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_user_enable[*]} -gt 0 ]] ||
        [[ ${#systemd_unit_system_mask[*]} -gt 0 ]]; then

        sudo systemctl daemon-reload

        for service in ${systemd_unit_system_enable[*]}; do
            if ! systemctl is-enabled --quiet $service &>/dev/null; then
                Info "Enabling systemmd system unit $service"
                sudo systemctl enable $service
            fi
        done

        for service in ${systemd_unit_user_enable[*]}; do
            if ! systemctl --user is-enabled --quiet $service &>/dev/null; then
                Info "Enabling systemmd user unit $service"
                systemctl --user enable $service
            fi
        done

        for service in ${systemd_unit_system_mask[*]}; do
            if ! systemctl list-unit-files --quiet --state=masked | grep $service &>/dev/null; then
                Info "Masking systemmd unit $service"
                sudo systemctl mask $service
            fi
        done
    fi
}

function HandleSystemdUnitsDisable() {
    for service in ${systemd_unit_system_disable[*]}; do
        if systemctl is-enabled --quiet $service &>/dev/null; then
            Info "Disabling systemmd system unit $service"
            sudo systemctl disable $service
        fi
    done
}
