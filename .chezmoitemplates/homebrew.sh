alias brew-kegs='brew info --json=v1 --installed | jq -r "map(select(.linked_keg == null) | .name)[]"'
alias brew-upgrade-routine='brew update --verbose && brew bundle --global --no-lock --cleanup && brew upgrade && brew cleanup --prune all -s'

# Prioritize kegs.
echo ${HOMEBREW_KEGS[@]} | xargs -I{} echo "${HOMEBREW_PREFIX}/opt/{}/bin" \
| xargs path-prepend

# Add the upgrade routine to the system's.
if ! [[ "${UPGRADE_ROUTINES[@]}" =~ 'brew-upgrade-routine' ]]
then
	UPGRADE_ROUTINES+='brew-upgrade-routine'
fi
