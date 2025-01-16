function aws-alb-privateDnsName-from-name
	aws ec2 describe-network-interfaces --output 'text' \
		--query 'NetworkInterfaces[*].PrivateIpAddresses[*].PrivateDnsName' \
		--filters Name='description',Values="ELB app/$argv[1]/*"
end
