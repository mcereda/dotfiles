alias dnf-system-upgrade-routine='sudo dnf makecache && sudo dnf distro-sync'

# Add the upgrade routine to the system's.
if ! [[ "${UPGRADE_ROUTINES[@]}" =~ 'dnf-system-upgrade-routine' ]]
then
	UPGRADE_ROUTINES+='dnf-system-upgrade-routine'
fi
