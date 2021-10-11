# Erase duplicates and ignore lines starting with spaces.
HISTCONTROL="ignorespace:erasedups"

# Set the number of lines or commands allowed in the history file.
HISTFILESIZE=100000

# Set the number of lines or commands stored in memory as history list during an
# ongoing session.
HISTSIZE=50000

# Format how history is stored.
HISTTIMEFORMAT="%Y-%m-%d %T  "

# Attempt to save all lines of a multiple-line command in the same history entry.
# This allows easy re-editing of multi-line commands.
shopt -s cmdhist

# Append the history list in memory to HISTFILE when exiting the shell, rather
# than overwriting the file.
shopt -s histappend

# If Readline is being used, load the results of history substitution into the
# editing buffer, allowing further modification before execution.
shopt -s histverify
