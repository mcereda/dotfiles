alias brew-kegs='brew info --json=v1 --installed | jq -r "map(select(.linked_keg == null) | .name)[]"'
alias brew-upgrade-routine='brew update --verbose && brew upgrade && brew cleanup --prune all -s'

# Add the upgrade routine to the system's.
if [[ ! "${UPGRADE_ROUTINES[@]}" =~ 'brew-upgrade-routine' ]]
then
	UPGRADE_ROUTINES+='brew-upgrade-routine'
fi
