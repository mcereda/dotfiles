function git-all
	argparse -s \
		'c/command=' \
		'e/executor=' \
		'p/path=+' \
		'r/recursive' \
		't/threads=' \
	-- $argv
	or return

	if ! set -q '_flag_executor'
		set '_flag_executor' 'parallel'
	end
	if ! set -q '_flag_path'
		set '_flag_path' "$PWD"
	end
	if ! set -q '_flag_recursive'
		set '_flag_recursive' '-r'
	end
	if ! set -q '_flag_threads'
		set '_flag_threads' (nproc)
	end

	echo "
	command: $_flag_command
	executor: $_flag_executor
	path: $_flag_path
	recursive: $_flag_recursive
	threads: $_flag_threads
	argv: $argv
	" | column -t

	if test "$_flag_recursive" = '-r' || test "$_flag_recursive" = '--recursive'
		# echo 'recursive test returned true'
		set repositories (find $_flag_path -type 'd' -name '.git' -exec dirname {} +)
	else
		# echo 'recursive test returned false'
		set repositories $_flag_path
	end

	# echo repositories: $repositories

	switch $_flag_executor
		case 'parallel'
			if ! which -s parallel
				echo "Error: GNU parallel not found" >&2
				return
			end
			parallel --color-failed -j "$_flag_threads" --tagstring "{/}" "git -C {} $_flag_command" ::: $repositories
		case 'xargs'
			echo  $repositories | xargs -tP "$_flag_threads" -I{} git -C "{}" $_flag_command
		case '*'
			echo "Error: $runner not supported" >&2
			return
	end
end
