function pulumi-list-resources
	pulumi stack export \
	| jq '.deployment.resources[]'
end
