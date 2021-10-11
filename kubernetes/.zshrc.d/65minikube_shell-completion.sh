if [[ -z "${MINIKUBE_COMPLETION_FILE}" ]]
then
  case "${SHELL##*/}" in
    "bash" | "zsh" )
      MINIKUBE_COMPLETION_FILE="${HOME}/.${SHELL##*/}rc.d/minikube.completion.${SHELL##*/}.inc"
      ;;
    "fish" )
      MINIKUBE_COMPLETION_FILE="${HOME}/.config/fish/completions/minikube.fish"
      ;;
  esac
fi

generate-minikube-completion-file () {
  [[ $DEBUG ]] && set -o xtrace
  
  minikube completion "${SHELL##*/}" > "${MINIKUBE_COMPLETION_FILE}"

  [[ $DEBUG ]] && set +o xtrace
}

if command which minikube >/dev/null 2>&1
then

  # add completion
  [[ ! -r "${MINIKUBE_COMPLETION_FILE}" ]] && generate-minikube-completion-file
  case "${SHELL##*/}" in
    "bash" | "zsh" )
      . "${MINIKUBE_COMPLETION_FILE}"
      ;;
  esac

fi
