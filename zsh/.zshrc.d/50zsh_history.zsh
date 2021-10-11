# The file to save the history in when an interactive shell exits.
# If unset, the history is not saved.
HISTFILE=~/.zhistory

# Set the number of lines or commands allowed in the history file
SAVEHIST=50000

# Set the number of lines or commands stored in memory as history list during an
# ongoing session
HISTSIZE=100000

# Append the session's history list to the history file, rather than replace it.
# Multiple parallel sessions will all have the new entries from their history
# lists added to the history file, in the order that they exit. The file will
# still be periodically re-written to trim it when the number of lines grows 20%
# beyond the value specified by $SAVEHIST
setopt append_history

# When searching for history entries in the line editor, do not display
# duplicates of a line previously found
# setopt hist_find_no_dups

# If a new command line being added to the history list duplicates an older one,
# the older command is removed from the list
setopt hist_ignore_all_dups

# Remove command lines from the history list when the first character on the
# line is a space, or when one of the expanded aliases contains a leading space.
# Only normal aliases (not global or suffix aliases) have this behaviour. Note
# that the command lingers in the internal history until the next command is
# entered before it vanishes, allowing you to briefly reuse or edit the line.
# If you want to make it vanish right away without entering another command,
# type a space and press return
setopt hist_ignore_space

# Remove superfluous blanks from each command line being added to the history
setopt hist_reduce_blanks

# Omit older commands duplicating newer ones when writing out the history file
# setopts hist_save_no_dups

# Whenever the user enters a line with history expansion, perform history
# expansion and reload the line into the editing buffer instead of executing it
setopt hist_verify
