function aws-ec2-nameTag-from-instanceId
	aws ec2 describe-instances --output 'text' \
	--filters "Name=instance-id,Values=$argv[1]" \
	--query "Reservations[].Instances[0].Tags[?(@.Key=='Name')].Value"
end
