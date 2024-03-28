function aws-iam-role-arn-from-name
	aws iam list-roles --output 'text' \
		--query "Roles[?RoleName == '$argv[1]'].Arn"
end
