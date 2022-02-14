alias brew-upgrade-routine='brew update --verbose && brew upgrade && brew cleanup --prune all -s'
alias brew-kegs='brew info --json=v1 --installed | jq -r "map(select(.linked_keg == null) | .name)[]"'
