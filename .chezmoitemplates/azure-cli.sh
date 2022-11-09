alias az-login-again-if-expired='az account show >/dev/null || az login --use-device-code'
alias az-sp-displayName-from-id="az ad sp show --query 'displayName' -o tsv --id"

az-helm-chart-versions () {
	is-true "$DEBUG" && enable-xtrace

	local AZURE_CONTAINER_REGISTRY="${1:-${AZURE_CONTAINER_REGISTRY:?required but not set}}"
	local AZURE_SUBSCRIPTION="${AZURE_SUBSCRIPTION:?required but not set}"
	local CHART_REGEXP="${2:=$CHART_REGEXP:=*}"
	local ENTRIES_LIMIT="${3:=${ENTRIES_LIMIT:-5}}"

	az acr helm list --output yaml \
		-n "$AZURE_CONTAINER_REGISTRY" --subscription "$AZURE_SUBSCRIPTION" \
	| yq -y --arg CHART_REGEXP "$CHART_REGEXP" \
		'to_entries
			| map(select(.key | test($CHART_REGEXP)))[].value[]
			| {version: .version,created: .created}' \
		- \
	| yq -sy "sort_by(.created) | reverse | .[0:${ENTRIES_LIMIT}]" -

	local RETURN_VALUE=$?
	is-true "$DEBUG" && disable-xtrace
	return $RETURN_VALUE
}

az-image-tags () {
	is-true "$DEBUG" && enable-xtrace

	local AZURE_CONTAINER_REGISTRY="${1:-${AZURE_CONTAINER_REGISTRY:?required but not set}}"
	local AZURE_SUBSCRIPTION="${AZURE_SUBSCRIPTION:?required but not set}"
	local IMAGE_NAME="${2:=${IMAGE_NAME:?required but not set}}"
	local ENTRIES_LIMIT="${3:=${ENTRIES_LIMIT:-5}}"

	az acr repository show-tags --output yaml \
		-n "$AZURE_CONTAINER_REGISTRY" --subscription "$AZURE_SUBSCRIPTION" \
		--repository "$IMAGE_NAME" \
	| yq -sy ".[] | reverse | .[0:${ENTRIES_LIMIT}]" -

	local RETURN_VALUE=$?
	is-true "$DEBUG" && disable-xtrace
	return $RETURN_VALUE
}

az-reset () {
	is-true "$DEBUG" && enable-xtrace

	local AZURE_SUBSCRIPTION="${AZURE_SUBSCRIPTION:?required but not set}"
	local SET_SUBSCRIPTION="${SET_SUBSCRIPTION:=true}"
	local RETURN_VALUE=1

	az account clear
	az login --use-device-code
	RETURN_VALUE=$?

	if is-true "$SET_SUBSCRIPTION"
	then
		az account set --subscription "$AZURE_SUBSCRIPTION"
		RETURN_VALUE=$?
	fi

	is-true "$DEBUG" && disable-xtrace
	return $RETURN_VALUE
}
