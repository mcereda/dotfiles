####################
# Python.
#
# See also:
# - https://docs.python.org/3/using/cmdline.html#environment-variables
####################

PYTHONCACHE=1
PYTHONGLOBALREQUIREMENTFILES=(
	"${HOME}/.local/lib/python/requirement.txt"
)

PYTHONCACHEDIROPTIONS=()
if ! is-true "$PYTHONCACHE"
then
	PYTHONCACHEDIROPTIONS+=( '--no-cache-dir' )
fi

PYTHONGLOBALREQUIREMENTOPTIONS=()
for FILE in ${PYTHONGLOBALREQUIREMENTFILES[@]}
do
	if [[ -r "$FILE" ]]
	then
		PYTHONGLOBALREQUIREMENTOPTIONS+=( "--requirement $FILE" )
	fi
done

{{-    if or
         (lookPath "pip2")
         (lookPath "pip3") }}

alias python-upgrade-all='pip install -U ${PYTHONCACHEDIROPTIONS[@]} --requirement <(pip freeze | sed "s/==/>=/")'
alias python-upgrade-global-requirement='pip install -U ${PYTHONCACHEDIROPTIONS[@]} ${PYTHONGLOBALREQUIREMENTOPTIONS[@]}'
alias python-upgrade-pip='pip install -U ${PYTHONCACHEDIROPTIONS[@]} pip'

alias python-user-upgrade-all='python-upgrade-all --user'
alias python-user-upgrade-global-requirement='python-upgrade-global-requirement --user'
alias python-user-upgrade-pip='python-upgrade-pip --user'

alias python-upgrade-routine='python-user-upgrade-global-requirement'

# Add the upgrade routine to the system's.
if [[ ! "${UPGRADE_ROUTINES[@]}" =~ 'python-upgrade-routine' ]]
then
	UPGRADE_ROUTINES+=( 'python-upgrade-routine' )
fi

{{-    end }}
