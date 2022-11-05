alias mas-upgrade-routine='mas upgrade'

# Add the upgrade routine to the system's.
if ! [[ "${UPGRADE_ROUTINES[@]}" =~ 'mas-upgrade-routine' ]]
then
	UPGRADE_ROUTINES+='mas-upgrade-routine'
fi
