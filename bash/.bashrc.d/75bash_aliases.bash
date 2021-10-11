alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias pip3-upgrade="pip3 list --user --outdated --format=json | jq -r '.[].name' - | xargs --verbose pip3 install --user --upgrade"

alias please='sudo'

alias uncomment='grep -Ev "^#|^$"'

# History.
# alias redo='$(fc -ln -1)'
alias redo='$(history -p !!)'
alias sedo='sudo $(history -p !!)'
