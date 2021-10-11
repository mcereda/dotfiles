# Execute a git command (with option) in all the repositories in the given path
git-all () {
  [[ $DEBUG ]] && set -o xtrace

  local COMMAND
  local FOLDERS=()
  for (( I = $# ; I >= 0 ; I-- )); do
    if [[ -d ${@[$I]} ]]; then
      FOLDERS+=${@[$I]}
    else
      case "${SHELL##*/}" in
        "bash" )
          COMMAND="${@:1: -${#FOLDERS}}"
          ;;
        "zsh" )
          COMMAND="${@[1,-$((${#FOLDERS}+1))]}"
          ;;
      esac
      break
    fi
  done

  if [[ -z "$COMMAND" ]]; then
    echo "error: no command given" >&2
    return
  fi

  local REPOSITORIES="$(find ${FOLDERS[@]:-'.'} -type d -name .git -exec dirname '{}' \;)"
  local PARALLELIZER="$(which parallel xargs | grep -iv "not found" | head -n 1)"

  if [[ "${OSTYPE}" =~ "darwin" ]]; then
    brew list | grep --quiet parallel || PARALLELIZER="$(which xargs | head -n 1)"
  fi

  if [[ ${#REPOSITORIES[@]} -eq 0 ]]; then
    echo "warning: no repositories found in the given folders" >&2
    echo "nothing to do"
    return
  fi

  case "${PARALLELIZER}" in
    */parallel )
      parallel --group --jobs 100% --tagstring {/} "git -C {} ${COMMAND}" ::: "${REPOSITORIES[@]}"
      ;;
    */xargs )
      echo -n ${REPOSITORIES[@]} | xargs --delimiter ' ' --max-lines --max-procs 0 --replace git -C {} ${COMMAND}
      ;;
    * )
      for REPOSITORY in ${REPOSITORIES[@]}; do
        echo -e "\n\n---\n${REPOSITORY}"
        git -C ${REPOSITORY} ${COMMAND}
      done
      ;;
  esac

  [[ $DEBUG ]] && set +o xtrace
}
