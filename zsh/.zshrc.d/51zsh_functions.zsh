# Prepend one or more given paths to PATH
# Do it only if they exist and are not already present
add-to-path () {
	[[ $DEBUG ]] && set -o xtrace

	if command which realpath >/dev/null 2>&1
	then
		path=( $(realpath --canonicalize-existing --no-symlinks --quiet $@ ${path[@]}) )
	else
		for GIVEN_PATH in $@
		do
			case ":${PATH}:" in
				*":${GIVEN_PATH}:"*)
					# the given path is already present
					# do nothing
					;;
				*)
					# prepend the given path (if it exists) to the PATH variable
					if [[ -d $GIVEN_PATH ]]
					then
						PATH="${GIVEN_PATH}:${PATH}"
					fi
					;;
			esac
		done
	fi

	[[ $DEBUG ]] && set +o xtrace
}

# Ask the user to confirm an action.
ask-for-confirmation () {
	[[ -n $DEBUG ]] && set -o xtrace

	vared -ep "Continue? " -c REPLY

	if [[ ! "$REPLY" =~ ^[Yy][Ee]?[Ss]?$ ]]
	then
		echo aborting
		return 1
	fi

	[[ -n $DEBUG ]] && set +o xtrace
}

# FIXME
backup () {
	[[ $DEBUG ]] && set -o xtrace

	DATETIME=$(date +'%F_%T')

	echo "Changes:"
	rsync --archive --delete --dry-run --verbose --exclude "*.bak*" ${HOME}/Documents /backup/

	if ask-for-confirmation
	then
		rsync --archive --backup --suffix ".bak_${DATETIME}" --delete --verbose --exclude "*.bak*" ${HOME}/Documents /backup/
	fi

	[[ $DEBUG ]] && set +o xtrace
}

# Return 0 if this is an interactive shell or 1 otherwise.
is-interactive-shell () {
	if [[ ! -o interactive ]]
	then
		return 1
	fi
}

# Return 0 if this is a login shell or 1 otherwise.
is-login-shell () {
	if [[ ! -o login ]]
	then
		return 1
	fi
}

# Show a rendered markdown file.
alias mdv='markdown-view'
markdown-view () {
	[[ $DEBUG ]] && set -o xtrace

	if [[ $# -lt 1 ]]
	then
		echo "error: no input files given" >&2
		echo "usage: $0 FILE..."
		return 1
	fi

	local REQUIREMENTS=(
		"lynx"
		"pandoc"
	)
	for REQUIREMENT in ${REQUIREMENTS[@]}
	do
		if command which $REQUIREMENT >/dev/null 2>&1
		then
			echo "error: ${REQUIREMENT} not found" >&2
			return 1
		fi
	done

	pandoc $@ | lynx -stdin

	[[ $DEBUG ]] && set +o xtrace
}

# Swap two files given in input.
swap () {
	[[ $DEBUG ]] && set -o xtrace

	if [[ ! $# -eq 2 ]]
	then
		echo "Usage: $0 FILE1 FILE2"
		echo "Example: $0 /etc/resolv.conf resolv.new"
		return 1
	fi

	local TMPFILE=tmp.$$
	mv "$1" $TMPFILE
	mv "$2" "$1"
	mv $TMPFILE "$2"

	[[ $DEBUG ]] && set +o xtrace
}
