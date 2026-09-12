function pulumi-all-of-type
	pulumi stack export \
	| jq -r --arg type "$argv[1]" '.deployment.resources[]|select(.type==$type).urn'
end
