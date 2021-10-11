alias broken-links='find . -type l -exec test ! -e {} \; -print'
alias dead-links='broken-links'

alias chime-webapp='chromium-browser -app=https://app.chime.aws/ --new-window &'

alias copy='xclip -selection clipboard <'

alias hibernate='pkexec systemctl hibernate'

# Enable colors.
alias grep='grep --color=always'
alias ls='ls --color=auto'

# Get the number of available threads in the system.
# nproc should be available by default, but if not just uncomment this.
# nproc='grep -c processor /proc/cpuinfo'

alias open='xdg-open'

alias snap-clean='snap list --all | grep disabled | awk "{print \$3, \$1}" | xargs -I {} sh -c "sudo snap remove --purge --revision {}"'

alias systemctl-failed='systemctl list-units --state failed'

if ! command which vim >/dev/null 2>&1 && command which vim.tiny >/dev/null 2>&1
then
	alias vim='vim.tiny'
fi
