# Examples:
# - $ pulumi-urnRegex2urn 'gitlab_ee_main_instance$'
#   urn:pulumi:dev::start::aws:ec2/instance:Instance::gitlab_ee_main_instance

function pulumi-urnRegex2urn
	pulumi stack export | \
	jq -r --arg regex "$argv[1]" '.deployment.resources[]|select(.urn|test($regex)).urn'
end
