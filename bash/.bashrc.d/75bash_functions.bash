# Prepend one or more given paths to PATH
# Do it only if they exist and are not already present
add-to-path () {
	[[ $DEBUG ]] && set -o xtrace

	for GIVEN_PATH in $@; do
		case ":${PATH}:" in
			*":${GIVEN_PATH}:"*) ;;                                     # given path is already present
			*) [[ -e $GIVEN_PATH ]] && PATH="${GIVEN_PATH}:${PATH}" ;;  # prepend to PATH
		esac
	done

	[[ $DEBUG ]] && set +o xtrace
}

# Ask the user to confirm an action.
ask-for-confirmation () {
	[[ $DEBUG ]] && set -o xtrace

	read -p 'Continue? ' REPLY

	if [[ ! $REPLY =~ '^[Yy][Ee]?[Ss]?$' ]]
	then
		echo "aborting"
		return 1
	fi

	[[ $DEBUG ]] && set +o xtrace
}

backup () {
	[[ $DEBUG ]] && set -o xtrace

	DATETIME="$(date +'%F_%T')"

	echo "Changes:"
	rsync --archive --delete --dry-run --verbose --exclude "*.bak*" "$HOME/Documents" /backup/
	ask-for-confirmation && rsync --archive --backup --suffix ".bak_$DATETIME" --delete --verbose --exclude "*.bak*" "$HOME/Documents" /backup/

	[[ $DEBUG ]] && set +o xtrace
}

# Return 0 if this is a login shell or 1 otherwise.
is-login-shell () {
	if [[ ! $0 =~ '-.*' ]] || [[ $(shopt login_shell) == 'on' ]]
	then
		return 1
	fi
}

alias mdv='markdown-view'
markdown-view () {
	[[ $DEBUG ]] && set -o xtrace

	if [[ ${#@} < 1 ]]
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

# Swap two files given in input
swap () {
	[[ $DEBUG ]] && set -o xtrace

	if [[ ! $# -eq 2 ]]
	then
		echo "Usage: $0 file1 file2"
		echo "Example: $0 /etc/resolv.conf resolv.new"
		return 1
	fi

	local TMPFILE=tmp.$$
	mv "$1" $TMPFILE && mv "$2" "$1" && mv $TMPFILE $2

	[[ $DEBUG ]] && set +o xtrace
}
