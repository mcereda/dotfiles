alias broken-links='find . -type l -not -path "*/Library/*" -exec test ! -e {} \; -print'
alias dead-links='broken-links'

# Enable colors.
alias grep='grep --color=always'
alias ls='ls -G'
alias diff='gdiff --color=always'

# Get the number of available threads in the system.
# nproc should be available by default, but if not just uncomment this.
# alias nproc='sysctl -n hw.logicalcpu'
