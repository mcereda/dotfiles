function pulumi-urn2id
	pulumi stack export | \
	jq -r --arg urn "$argv[1]" '.deployment.resources[]|select(.urn==$urn).id'
end
