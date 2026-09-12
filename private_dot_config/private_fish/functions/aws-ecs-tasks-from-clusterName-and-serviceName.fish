# Examples:
# - $ aws-ecs-tasks-from-clusterName-and-serviceName 'staging' 'loki'
#   {
#     "attachments": [ … ],
#     "attributes": [ … ],
#     "availabilityZone": "eu-west-1b",
#     …
#   }

function aws-ecs-tasks-from-clusterName-and-serviceName
	aws ecs list-tasks --cluster "$argv[1]" --output 'text' --query 'taskArns' \
	| xargs aws ecs describe-tasks --cluster "$argv[1]" \
		--query "tasks[?group.contains(@, '$argv[2]')]" --tasks
end
