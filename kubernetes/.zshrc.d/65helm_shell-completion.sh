if [[ -z "${HELM_COMPLETION_FILE}" ]]
then
  case "${SHELL##*/}" in
    "bash" | "zsh" )
      HELM_COMPLETION_FILE="${HOME}/.${SHELL##*/}rc.d/helm.completion.${SHELL##*/}.inc"
      ;;
    "fish" )
      HELM_COMPLETION_FILE="${HOME}/.config/fish/completions/helm.fish"
      ;;
  esac
fi

generate-helm-completion-file () {
  [[ $DEBUG ]] && set -o xtrace
  
  helm completion "${SHELL##*/}" > "${HELM_COMPLETION_FILE}"

  [[ $DEBUG ]] && set +o xtrace
}

if command which helm >/dev/null 2>&1
then

  # add completion
  [[ ! -r "${HELM_COMPLETION_FILE}" ]] && generate-helm-completion-file
  case "${SHELL##*/}" in
    "bash" | "zsh" )
      . "${HELM_COMPLETION_FILE}"
      ;;
  esac

fi
