alias broken-links='find . -type l -not -path "*/Library/*" -exec test ! -e {} \; -print'
alias dead-links='broken-links'

alias darwin-system-upgrade-routine='softwareupdate --list'

alias dns-clear-cache='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# Enable colors.
alias grep='grep --color=always'
alias ls='ls -G'

{{- if lookPath "gdiff" }}
alias diff='gdiff --color=always'
{{- end }}

# Get the number of available threads in the system.
# nproc should be available by default, but if not just uncomment this.
# alias nproc='sysctl -n hw.logicalcpu'

# Add the upgrade routine to the system's.
if ! [[ "${UPGRADE_ROUTINES[@]}" =~ 'darwin-system-upgrade-routine' ]]
then
	UPGRADE_ROUTINES+='darwin-system-upgrade-routine'
fi
