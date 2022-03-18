alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias please='sudo'
alias uncomment='grep -Ev "^#|^$"'

[[ -n "${UPGRADE_ROUTINES[@]}" ]] && alias upgrade-routine="${(j:; echo -e "\n---\n"; :)UPGRADE_ROUTINES}"

# History.
# alias redo='$(fc -ln -1)'
alias redo='$(history -p !!)'
alias sedo='sudo $(history -p !!)'
