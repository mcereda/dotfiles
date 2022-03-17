[[ -z "${UPGRADE_ROUTINES[@]}" ]] && UPGRADE_ROUTINES=()

UPGRADE_ROUTINES+='zypper-system-upgrade-routine'
