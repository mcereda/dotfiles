if [[ -z "${KUSTOMIZE_COMPLETION_FILE}" ]]
then
  case "${SHELL##*/}" in
    "bash" | "zsh" )
      KUSTOMIZE_COMPLETION_FILE="${HOME}/.${SHELL##*/}rc.d/kustomize.completion.${SHELL##*/}.inc"
      ;;
    "fish" )
      KUSTOMIZE_COMPLETION_FILE="${HOME}/.config/fish/completions/kustomize.fish"
      ;;
  esac
fi

generate-kustomize-completion-file () {
  [[ $DEBUG ]] && set -o xtrace
  
  kustomize completion "${SHELL##*/}" > "${KUSTOMIZE_COMPLETION_FILE}"

  [[ $DEBUG ]] && set +o xtrace
}

install-kustomize () {
  [[ $DEBUG ]] && set -o xtrace

  local VERSION="${1:-$VERSION}"
  local DESTINATION="${2:-$DESTINATION}"

  VERSION="${VERSION:-3.8.9}"

  case "$(uname -s)" in
    Darwin )
      DESTINATION="${DESTINATION:-$HOME/Applications/bin}"
      local FILENAME="kustomize_v${VERSION}_darwin_amd64.tar.gz"
      ;;
    * )
      echo "OS not supported"
      return 1
      ;;
  esac

  curl --continue-at - --location --output "/tmp/${FILENAME}" --progress-bar "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${VERSION}/${FILENAME}"
  tar --directory "/tmp" --extract --file "/tmp/${FILENAME}" --verbose
  mv -v /tmp/kustomize "${DESTINATION}/kustomize-${VERSION}"
  rm "/tmp/${FILENAME}"

  [[ $DEBUG ]] && set +o xtrace
}

if command which kustomize >/dev/null 2>&1
then

  # add completion
  [[ ! -r "${KUSTOMIZE_COMPLETION_FILE}" ]] && generate-kustomize-completion-file
  case "${SHELL##*/}" in
    "bash" | "zsh" )
      . "${KUSTOMIZE_COMPLETION_FILE}"
      ;;
  esac

fi
