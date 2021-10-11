# There are 3 different types of shells in bash: the login shell, normal shell
# and interactive shell. Login shells read ~/.profile and interactive shells
# read ~/.bashrc; in this setup, ~/.profile sources ~/.bashrc - thus all changes
# made here will also take effect in a login shell.
#
# This file is sourced by all *interactive* bash shells on startup, including
# some apparently interactive shells such as scp and rcp that can't tolerate
# any output.
# Make sure this doesn't display anything or bad things will happen!
#
# It is recommended to make language settings in ~/.profile rather than here,
# since multilingual X sessions would not work properly if LANG is overridden
# in every subshell.
#
# References:
# - https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html

# Test for an interactive shell.
# There is no need to set anything past this point for scp and rcp, and it's
# important to refrain from outputting anything in those cases.
if [[ $- != *i* ]]
then
	# Shell is non-interactive. Be done now!
	return
fi

# Lists the status of any stopped and running jobs before exiting an interactive
# shell. If any jobs are running, defer exiting until a second exit is attempted
# without an intervening command and always postpone exiting if any jobs are
# stopped.
shopt -s checkjobs

# Check the window size of the current terminal window after each command.
# If necessary, update the values of the LINES and COLUMNS variables.
shopt -s checkwinsize

# If Readline is being used, do not attempt to search PATH for possible
# completions when the line is empty and wait a long time for this.
shopt -s no_empty_cmd_completion

# Add "/" to links to directories in autocompletion.
set mark-symlinked-directories on


# Configuration modules.
# All files in the configuration folder will be automatically loaded in
# alphabetical order. The last file setting a value overrides the previous ones.
bash_modules_dir="${bash_modules_dir:-$HOME/.bashrc.d}"
if [[ -d "${bash_modules_dir}" ]]
then
	for module in ${bash_modules_dir}/*
	do
		[[ -r ${module} ]] && source "${module}"
	done
	unset module
fi


# Add custom PATHs.
if builtin type add-to-path >/dev/null 2>&1
then
	add-to-path ~/bin ~/.bin ~/.local/bin /usr/bin /usr/local/bin
fi
