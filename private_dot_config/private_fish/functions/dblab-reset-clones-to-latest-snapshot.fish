function dblab-reset-clones-to-latest-snapshot
	dblab clone list \
	| jq -r \
		--arg latest_snapshot $(dblab snapshot list | jq -r 'max_by(.createdAt).id') \
		'.[]|select(.snapshot.id != $latest_snapshot).id' - \
	| xargs -n1 -p dblab clone reset --latest
end
