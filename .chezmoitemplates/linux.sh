alias broken-links='find . -type l -exec test ! -e {} \; -print'
alias dead-links='broken-links'

{{- if lookPath "chromium-browser" }}
alias chime-webapp='chromium-browser -app=https://app.chime.aws/ --new-window &'
{{- end }}

alias copy='xclip -selection clipboard <'

# Enable colors.
alias grep='grep --color=always'
alias ls='ls --color=auto'

# Get the number of available threads in the system.
# nproc should be available by default, but if not just uncomment this.
# nproc='grep -c processor /proc/cpuinfo'

alias open='xdg-open'

{{- if and (not (lookPath "vim")) (lookPath "vim.tiny") }}
alias vim='vim.tiny'
{{- end }}
