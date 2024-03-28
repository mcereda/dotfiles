function pulumi-id2urn
	pulumi stack export | \
	jq -r --arg id "$argv[1]" '.deployment.resources[]|select(.id==$id).urn'
end
