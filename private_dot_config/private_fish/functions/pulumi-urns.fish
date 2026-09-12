function pulumi-urns
	pulumi stack export \
	| jq -r '.deployment.resources[].urn' - \
	| sort
end
