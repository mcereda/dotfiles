function aws-efs-mount-volume-locally-by-creation-token
	mkdir -p "/tmp/efs/$argv[1]"
	aws efs describe-file-systems --query 'FileSystems[].FileSystemId' --output 'text' --creation-token "$argv[1]" \
	| xargs aws efs describe-mount-targets --query 'MountTargets[].IpAddress|[0]' --output 'text' --file-system-id \
	| xargs -I '%%' mount -vt 'nfs' -o 'nfsvers=4,tcp,rwsize=1048576,hard,timeo=600,retrans=2,noresvport' "%%:/" "/tmp/efs/$argv[1]"
end
