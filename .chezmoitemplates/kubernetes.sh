{{-    if lookPath "az" }}

alias aks-versions='\
	az aks get-versions --output table \
		--location ${AZURE_LOCATION:?required but not set}'

{{-    end }}

alias eks-dashboard='\
	kubectl --namespace kube-system describe secret \
		$(kubectl --namespace kube-system get secrets | grep eks-admin | awk "{print \$1}") \
	&& echo "http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/ \
	&& kubectl proxy"'

kubectl-decode () { echo $1 | base64 -d ; } && alias k8s-decode='kube-decode'
kubectl-encode () { echo -n $1 | base64 ; } && alias k8s-encode='kube-encode'

kubectl-check-cluster-connection () {
	# `kubectl cluster-info` takes too long to be used on a prompt

	is-true "$DEBUG" && enable-xtrace

	local KUBE_CONTEXT="${KUBE_CONTEXT:-$(kubectl config current-context)}"
	local KUBE_CLUSTER="${KUBE_CLUSTER:-$(kubectl config view -o jsonpath="{.contexts[?(@.name == '${KUBE_CONTEXT}')].context.cluster}")}"
	local KUBE_SERVER="${KUBE_SERVER:=$(kubectl config view -o jsonpath="{.clusters[?(@.name == '${KUBE_CLUSTER}')].cluster.server}")}"

	curl --connect-timeout 1 --insecure --silent "$KUBE_SERVER" > /dev/null

	local RETURN_VALUE=$?
	is-true "$DEBUG" && disable-xtrace
	return $RETURN_VALUE
} && alias k8s-check-cluster-connection='kubectl-check-cluster-connection'

kubectl-delete-non-default-service-accounts () {
	local K8S_NAMESPACE="${K8S_NAMESPACE:=default}"

	kubectl --namespace "$K8S_NAMESPACE" delete serviceaccounts \
		$(kubectl --namespace "$K8S_NAMESPACE" get serviceaccounts \
			--output jsonpath="{.items[?(@.metadata.name!='default')].metadata.name}" \
			| tr ' ' ',')
} && alias k8s-delete-non-default-service-accounts='kubectl-delete-non-default-service-accounts'

alias k8s-get-nodes-issues=kube-get-nodes-issues
alias k8s-get-nodes-issues-yaml=kube-get-nodes-issues-yaml
alias kube-get-nodes-issues='kubectl get nodes -o json | jq '\''.items[] | {"node": .metadata.name, "issues": [.status.conditions[] | select(.status != "False")]}'\'' -'
alias kube-get-nodes-issues-yaml='kubectl get nodes -o yaml | yq -y '\''.items[] | {"node": .metadata.name, "issues": [.status.conditions[] | select(.status != "False")]}'\'' -'

# # kube-ps1 prompt customization
# # shell function, need to use built-in 'type'
# [[ -f /opt/kube-ps1/kube-ps1.sh ]] && . /opt/kube-ps1/kube-ps1.sh
# if builtin type kube_ps1 >/dev/null 2>&1
# then
# 	export KUBE_PS1_SYMBOL_ENABLE=false KUBE_PS1_PREFIX='[' KUBE_PS1_SUFFIX=']'
# 	export PS1='$(kube_ps1)'$PS1
# fi
