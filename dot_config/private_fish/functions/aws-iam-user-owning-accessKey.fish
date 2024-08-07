function aws-iam-user-owning-accessKey
	aws iam list-users --no-cli-pager --query 'Users[].UserName' --output 'text' | xargs -n '1' | shuf \
	| xargs -n 1 -P (nproc) aws iam list-access-keys --output 'json' \
		--query "AccessKeyMetadata[?AccessKeyId=='$argv[1]'].UserName" --user \
	| jq -rs 'flatten|first'
end
