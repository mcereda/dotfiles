function pulumi-list-resource-urns
	pulumi stack export \
	| jq -r '.deployment.resources[].urn'
end
