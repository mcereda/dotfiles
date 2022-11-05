alias apt-system-upgrade-routine='sudo apt update && sudo apt dist-upgrade'

# Add the upgrade routine to the system's.
if ! [[ "${UPGRADE_ROUTINES[@]}" =~ 'brew-upgrade-routine' ]]
then
	UPGRADE_ROUTINES+='apt-system-upgrade-routine'
fi
