function aws-ec2-instanceId-from-nameTag
	aws ec2 describe-instances --output 'text' \
	--filters "Name=tag:Name,Values=$argv[1]" \
	--query 'Reservations[].Instances[0].InstanceId'
end
