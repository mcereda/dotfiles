##########
# Zypper.
##########

alias zypper-system-upgrade-routine='sudo zypper refresh && sudo zypper dist-upgrade && sudo zypper ps --short'

# Add the upgrade routine to the system's.
if ! [[ "${UPGRADE_ROUTINES[@]}" =~ 'zypper-system-upgrade-routine' ]]
then
	UPGRADE_ROUTINES+='zypper-system-upgrade-routine'
fi
