alias port-cleanup='sudo port reclaim'
alias port-upgrade-routine='sudo port selfupdate && sudo port upgrade outdated && port-cleanup'

# Add the upgrade routine to the system's.
if ! [[ "${UPGRADE_ROUTINES[@]}" =~ 'port-upgrade-routine' ]]
then
	UPGRADE_ROUTINES+='port-upgrade-routine'
fi
