function SystemdUnitSystemEnable() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_unit_system_enable+=($1)
}

function SystemdUnitSystemDisable() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_unit_system_disable+=($1)
}

function SystemdUnitSystemMask() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_unit_system_mask+=($1)
}

function SystemdUnitSystemUnmask() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_unit_system_unmask+=($1)
}

function SystemdUnitUserEnable() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_unit_user_enable+=($1)
}

function SystemdUnitUserDisable() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_unit_user_disable+=($1)
}

function SystemdUnitUserMask() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_unit_user_mask+=($1)
}

function SystemdUnitUserUnmask() {
    ValidateExactFunctionParams 1 $# $FUNCNAME

    systemd_unit_user_unmask+=($1)
}
