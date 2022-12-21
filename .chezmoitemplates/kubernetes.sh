alias kubectl-current-context='kubectl config current-context'

kubectl-decode () { echo "$1" | base64 -d ; }
kubectl-encode () { echo -n "$1" | base64 ; }

kubectl-current-cluster () {
	is-true "$DEBUG" && enable-xtrace

	kubectl config view \
		-o jsonpath="{.contexts[?(@.name == '${KUBECONTEXT:-$(kubectl-current-context)}')].context.cluster}"

	local RETURN_VALUE=$?
	is-true "$DEBUG" && disable-xtrace
	return $RETURN_VALUE
}

kubectl-current-server () {
	is-true "$DEBUG" && enable-xtrace

	kubectl config view \
		-o jsonpath="{.clusters[?(@.name == '${KUBECLUSTER:-$(kubectl-current-cluster)}')].cluster.server}"

	local RETURN_VALUE=$?
	is-true "$DEBUG" && disable-xtrace
	return $RETURN_VALUE
}

# `kubectl cluster-info` takes too long to be used on a prompt
kubectl-check-cluster-connection () {
	is-true "$DEBUG" && enable-xtrace

	local TIMEOUT="1"
	curl --connect-timeout "$TIMEOUT" --insecure --silent "${KUBESERVER:-$(kubectl-current-server)}" > /dev/null

	local RETURN_VALUE=$?
	is-true "$DEBUG" && disable-xtrace
	return $RETURN_VALUE
}

kubectl-delete-non-default-service-accounts () {
	is-true "$DEBUG" && enable-xtrace

	KUBEOPTIONS+=( '--namespace' "${KUBENAMESPACE:-default}" )

	kubectl ${KUBEOPTIONS[@]} get serviceaccounts \
		--output jsonpath="{.items[?(@.metadata.name!='default')].metadata.name}" \
	| tr ' ' ',' \
	| xargs kubectl ${KUBEOPTIONS[@]} delete serviceaccounts

	local RETURN_VALUE=$?
	is-true "$DEBUG" && disable-xtrace
	return $RETURN_VALUE
}

kubectl-nodes-with-issues () {
	kubectl get nodes -o jsonpath='{.items[]}' \
	| jq '
		{
			"node": .metadata.name,
			"issues": [
				.status.conditions[] | select(
					.status != "False" and
					.type != "Ready"
				)
			]
		} | select( .issues|length > 0 )
	' -
}
alias kubectl-nodes-with-issues-in-yaml='kubectl-nodes-with-issues | yq -y "." -'

# # kube-ps1 prompt customization
# # shell function, need to use built-in 'type'
# [[ -f /opt/kube-ps1/kube-ps1.sh ]] && . /opt/kube-ps1/kube-ps1.sh
# if builtin type kube_ps1 >/dev/null 2>&1
# then
# 	export KUBE_PS1_SYMBOL_ENABLE=false KUBE_PS1_PREFIX='[' KUBE_PS1_SUFFIX=']'
# 	export PS1='$(kube_ps1)'$PS1
# fi

{{-    if lookPath "az" }}

##########
# AKS.
# Managed Kubernetes from Microsoft Azure.
##########

alias aks-versions='\
	az aks get-versions --output table \
		--location ${AZURE_LOCATION:?required but not set}'

{{-    end }}

{{-    if lookPath "awscli" }}

##########
# EKS.
# Managed Kubernetes from Amazon Web Services.
##########

alias eks-dashboard='\
	kubectl --namespace kube-system describe secret \
		$(kubectl --namespace kube-system get secrets | grep eks-admin | awk "{print \$1}") \
	&& echo "http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/ \
	&& kubectl proxy"'

{{-    end }}
