MINIKUBE_IN_STYLE=false

if [[ -z "${KUBECTL_COMPLETION_FILE}" ]]
then
  case "${SHELL##*/}" in
    "bash" | "zsh" )
      KUBECTL_COMPLETION_FILE="${HOME}/.${SHELL##*/}rc.d/kubectl.completion.${SHELL##*/}.inc"
      ;;
    "fish" )
      KUBECTL_COMPLETION_FILE="${HOME}/.config/fish/completions/kubectl.fish"
      ;;
  esac
fi

alias kube-dashboard='kubectl --namespace kube-system describe secret $(kubectl --namespace kube-system get secret | grep eks-admin | awk "{print \$1}") && echo "http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/ && kubectl proxy"'

kube-decode () { echo $1 | base64 -d }
kube-encode () { echo -n $1 | base64 }

install-kubectl () {
  # https://kubernetes.io/docs/tasks/tools/install-kubectl/

  [[ $DEBUG ]] && set -o xtrace

  local VERSION="${1:-$VERSION}"
  local DESTINATION="${2:-$DESTINATION}"

  LATEST_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt | sed 's/v//')
  VERSION="${VERSION:-$LATEST_VERSION}"

  case "$(uname -s)" in
    Darwin )
      DESTINATION="${DESTINATION:-$HOME/bin}"
      local OS=darwin
      ;;
    * )
      echo "OS not supported"
      return 1
      ;;
  esac

  curl --continue-at - --location --output "${DESTINATION}/kubectl-${VERSION}" "https://dl.k8s.io/release/v${VERSION}/bin/${OS}/amd64/kubectl"
  chmod a+x "${DESTINATION}/kubectl-${VERSION}"

  [[ $DEBUG ]] && set +o xtrace
}

generate-kubectl-completion-file () {
  [[ $DEBUG ]] && set -o xtrace
  
  kubectl completion "${SHELL##*/}" > "${KUBECTL_COMPLETION_FILE}"

  [[ $DEBUG ]] && set +o xtrace
}

kubectl-quick-check-connection-to-cluster () {
  # kubectl cluster-info takes too long to be used on a prompt

  [[ $DEBUG ]] && set -o xtrace

  local CONTEXT=$(kubectl config current-context)
  local CLUSTER=$(kubectl config view -o jsonpath="{.contexts[?(@.name == '${CONTEXT}')].context.cluster}")
  local SERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name == '${CLUSTER}')].cluster.server}")
  curl --connect-timeout 1 --insecure --silent $SERVER > /dev/null

  [[ $DEBUG ]] && set +o xtrace
}

# kube-ps1 prompt customization
# shell function, need to use built-in 'type'
[[ -f /opt/kube-ps1/kube-ps1.sh ]] && . /opt/kube-ps1/kube-ps1.sh
if builtin type kube_ps1 >/dev/null 2>&1
then
  export KUBE_PS1_SYMBOL_ENABLE=false KUBE_PS1_PREFIX='[' KUBE_PS1_SUFFIX=']'
  export PS1='$(kube_ps1)'$PS1
fi

if command which kubectl >/dev/null 2>&1
then

  # add completion
  [[ ! -r "${KUBECTL_COMPLETION_FILE}" ]] && generate-kubectl-completion-file
  case "${SHELL##*/}" in
    "bash" | "zsh" )
      . "${KUBECTL_COMPLETION_FILE}"
      ;;
  esac

fi

# minikube
if command which minikube >/dev/null 2>&1
then

  # add completion
  # not needed if using oh-my-zsh with the minikube plugin enabled
  if ! ( echo $plugins | grep --silent "minikube" )
  then
    case "${SHELL##*/}" in
      "bash" | "zsh" )
        . <(minikube completion ${SHELL##*/})
        ;;
      "fish" )
        minikube completion fish > "${HOME}/.config/fish/completions/minikube.fish"
        ;;
    esac
  fi

fi
