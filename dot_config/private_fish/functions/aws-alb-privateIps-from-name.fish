function aws-alb-privateIps-from-name
	aws ec2 describe-network-interfaces --output 'text' \
		--query 'NetworkInterfaces[*].PrivateIpAddresses[*].PrivateIpAddress' \
		--filters Name='description',Values="ELB app/$argv[1]/*"
end
