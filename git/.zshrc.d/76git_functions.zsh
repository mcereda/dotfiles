# Execute a git command (with option) in all the repositories in the given path
git-all () {
  [[ -n $DEBUG ]] && set -o xtrace

  local COMMAND
  local FOLDERS=()
  for (( I = $# ; I >= 0 ; I-- )); do
    if [[ -d ${@[$I]} ]]; then
      FOLDERS+=${@[$I]}
    else
      COMMAND="${@[1,-$((${#FOLDERS}+1))]}"
      break
    fi
  done

  if [[ -z "$COMMAND" ]]; then
    echo "error: no command given" >&2
    return
  fi

  local REPOSITORIES=( $(find ${FOLDERS[@]:-'.'} -type d -name .git -exec dirname '{}' \;) )
  PARALLELIZER="${PARALLELIZER:-$(command which parallel xargs 2>/dev/null | head -n 1)}"

  if [[ ${#REPOSITORIES[@]} -eq 0 ]]; then
    echo "error: no repositories found in the given folders" >&2
    echo "nothing to do"
    return 1
  fi

  case ${PARALLELIZER##*/} in
    "parallel" )
      parallel --group --jobs 100% --tag "git -C {} ${COMMAND}" ::: ${REPOSITORIES[@]}
      ;;
    "xargs" )
      case $OSTYPE in
        linux* )
          echo -n ${REPOSITORIES[@]} | xargs --delimiter ' ' -t --max-procs 0 --replace git -C "{}" $(echo ${COMMAND[@]})
          ;;
        * )
          echo -n ${REPOSITORIES[@]} | xargs -n 1 -P 0 -I {} git -C "{}" $(echo ${COMMAND[@]})
          ;;
      esac
      ;;
    * )
      for REPOSITORY in ${REPOSITORIES[@]}; do
        echo -e "\n\n---\n${REPOSITORY}"
        git -C $REPOSITORY $COMMAND
      done
      ;;
  esac

  [[ -n $DEBUG ]] && set +o xtrace
}
