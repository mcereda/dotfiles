alias snap-cleanup='\
	snap list --all \
		| grep disabled | awk "{print \$3, \$1}" \
		| xargs -I {} sh -c "sudo snap remove --purge --revision {}"'
alias snap-upgrade-routine="sudo snap refresh"

# Add the upgrade routine to the system's.
if ! [[ "${UPGRADE_ROUTINES[@]}" =~ 'snap-upgrade-routine' ]]
then
	UPGRADE_ROUTINES+='snap-upgrade-routine'
fi
