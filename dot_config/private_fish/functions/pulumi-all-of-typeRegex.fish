# Examples:
# - $ pulumi-all-of-typeRegex 'Endpoint$'
#   urn:pulumi:dev::ds::aws:sagemaker/endpoint:Endpoint::bestMlEvah

function pulumi-all-of-typeRegex
	pulumi stack export | \
	jq -r --arg regex "$argv[1]" '.deployment.resources[]|select(.type|test($regex)).urn'
end
