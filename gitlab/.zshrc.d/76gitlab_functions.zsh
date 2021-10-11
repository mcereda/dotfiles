gitlab-delete-offline-runners () {
  [[ $DEBUG ]] && set -o xtrace

  local DRY_RUN="${DRY_RUN}:-false"

  local URL="${URL:-gitlab.example.com}"
  local BASEURL="${BASEURL:-https://$URL/api/v4}"
  local TARGET="${BASEURL}/runners/all?status=offline"
  [[ $PER_PAGE ]] && TARGET="${TARGET}&per_page=${PER_PAGE}"

  local TOKEN="${TOKEN:?unset}"

  local TEMP_DIR="$(mktemp -d /tmp/$(basename ${0}).XXX)"
  local RESPONSE_HEADERS="$(mktemp ${TEMP_DIR}/headers.txt)"

  echo "getting a list of all offline runners"
  # has to deal with gitlab apis pagination
  local RUNNER_IDS=()
  while [[ -n "${TARGET}" ]]; do
    RUNNER_IDS+=(
      $(curl "${TARGET}" \
        --silent \
        --fail \
        --dump-header "${RESPONSE_HEADERS}" \
        --header "PRIVATE-TOKEN: ${TOKEN}" \
        | jq -r '.[]|select(.status == "offline")|.id' -)
    )
    TARGET="$(grep "link:" "${RESPONSE_HEADERS}" | awk -F '; rel="next"' '{print $1}' | sed -E 's/.*(http.*)>/\1/')"
  done
  rm -rf "${TEMP_DIR}"

  if [[ ${#RUNNER_IDS[@]} -eq 0 ]]; then
    echo "nothing to do"
  else
    for RUNNER_ID in ${RUNNER_IDS[@]}; do
      echo "deleting runner ${RUNNER_ID}…"
      [[ $DRY_RUN ]] || curl --request DELETE --header "PRIVATE-TOKEN: ${TOKEN}" "${BASEURL}/runners/${RUNNER_ID}"
    done
  fi

  [[ $DEBUG ]] && set +o xtrace
}

gitlab-get-project-info-by-id () {
  [[ $DEBUG ]] && set -o xtrace

  local URL="${URL:-gitlab.example.com}"
  local BASEURL="${BASEURL:-https://$URL/api/v4}"
  local TARGET="${BASEURL}/projects/${1}"

  local TOKEN="${TOKEN:?unset}"

  curl "${TARGET}" \
    --silent \
    --fail \
    --header "PRIVATE-TOKEN: ${TOKEN}" \
    | jq '.' -

  [[ $DEBUG ]] && set +o xtrace
}
