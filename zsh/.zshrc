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


# Enable this and the last line to debug performance.
# zmodload zsh/zprof


# Basic settings.
# Setup sane defaults that could easily be overridden later.

# Require the use of cd to change directory.
unsetopt auto_cd

# If a pattern for filename generation has no matches, print an error instead of
# leaving it unchanged in the argument list.
# This also applies to file expansion of an initial '~' or '='.
setopt no_match

# Let compinstall find where it wrote zstyle statements for you last time.
# This lets you run compinstall again to update them.
zstyle ':compinstall' filename ~/.zshrc

# Automatically update completions after PATH changes.
zstyle ':completion:*' rehash true

# Enable cache for the completions.
zstyle ':completion:*' use-cache true

# Ensure PATH contains some needed directories.
path=(
	~/bin
	~/.bin
	~/.local/bin
	/usr/bin
	/usr/local/bin
	${path[@]}
)


# Configuration modules.
# All files in the configuration folder will be automatically loaded in
# numeric order. The last file setting a value overrides the previous ones.
# Links are only sourced if their reference exists.
zsh_modules_dir="${zsh_modules_dir:-$HOME/.zshrc.d}"
if [[ -d "${zsh_modules_dir}" ]]
then
	for module in ${zsh_modules_dir}/*
	do
		[[ -r ${module} ]] && source "${module}"
	done
	unset module
fi


# Configuration freeze.
# Finalize customizations and try to set the current configuration immutable.

# Load extensions.
autoload -Uz compinit promptinit

# Enable completions.
compinit

# Enable prompt management.
promptinit


# Clean up PATH and FPATH.

# Remove non-existing directories, follow symlinks and clean up remaing paths.
if command which realpath >/dev/null 2>&1
then
  fpath=( $(realpath --canonicalize-existing --no-symlinks --quiet ${fpath[@]}) )
  path=(  $(realpath --canonicalize-existing --no-symlinks --quiet ${path[@]})  )
fi

# Make PATH's and FPATH's entries unique for better performances.
typeset -aU fpath path


# Freeze (-f) or unfreeze (-u) the tty. When the tty is frozen, no changes made
# to the tty settings by external programs will be honored by the shell, except
# for changes in the size of the screen; the shell will simply reset the
# settings to their previous values as soon as each command exits or is
# suspended.
# Freezing the tty only causes future changes to the state to be blocked.
ttyctl -f


# Enable this and the module inclusion on the first line to debug performance.
# zprof
