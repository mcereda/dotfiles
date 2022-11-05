alias portage-active-features='portageq envvar FEATURES | xargs -n 1'

alias system-cleanup='sudo emerge --depclean --ask'
alias system-sync='sudo ego sync && sudo emerge --sync'
alias system-update='sudo emerge --quiet --verbose --update --deep --newuse --changed-use --with-bdeps=y --ask @world'
alias system-update-and-cleanup='system-sync && system-update && system-cleanup'

# Add the upgrade routine to the system's.
UPGRADE_ROUTINES+='system-update-and-cleanup'
