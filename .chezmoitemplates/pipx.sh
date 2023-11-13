{{-    if lookPath "pipx" -}}

alias pipx-upgrade-all='pipx upgrade-all'

alias pipx-upgrade-routine='pipx-upgrade-all'

# Add the upgrade routine to the system's.
if [[ ! "${UPGRADE_ROUTINES[@]}" =~ 'pipx-upgrade-routine' ]]
then
	UPGRADE_ROUTINES+=( 'pipx-upgrade-routine' )
fi

{{-    end }}
