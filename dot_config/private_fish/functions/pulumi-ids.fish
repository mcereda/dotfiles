function pulumi-ids
	pulumi stack export \
	| jq -r '.deployment.resources[].id' - \
	| sort
end
