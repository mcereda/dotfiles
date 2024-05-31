# Examples:
# - $ aws-ec2-tag-from-instanceId 'i-078fbf8dbb5742649' 'Name'
#   Bastion

function aws-ec2-tag-from-instanceId
	aws ec2 describe-instances --output 'text' \
	--filters "Name=instance-id,Values=$argv[1]" \
	--query "Reservations[].Instances[0].Tags[?(@.Key=='$argv[2]')].Value"
end
