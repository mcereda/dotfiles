function aws-ec2-tags-from-instanceId
	aws ec2 describe-instances --output 'table' \
	--filters "Name=instance-id,Values=$argv[1]" \
	--query 'Reservations[].Instances[0].Tags[]'
end
