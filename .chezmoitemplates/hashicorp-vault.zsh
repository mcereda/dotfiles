# Load autocompletion.
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C $(which vault) vault
