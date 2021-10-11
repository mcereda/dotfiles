# Antigen needs git to work.
if ! command which git >/dev/null 2>&1
then
	echo "Error: Antigen needs git to work" >&2
	return 1
fi

# Download Antigen if missing.
ANTIGEN_HOME="${ANTIGEN_HOME:-$HOME/.local/share}/antigen"
ANTIGEN_INIT="${ANTIGEN_HOME}/antigen.zsh"
[[ ! -d "$ANTIGEN_HOME" ]] && mkdir --parents "$ANTIGEN_HOME"
if [[ ! -e "$ANTIGEN_INIT" ]]
then
	echo -n "Getting latest version of antigen... "
	curl --location --silent git.io/antigen > $ANTIGEN_INIT
	echo "done"
fi

# Where to keep all Antigen data.
ADOTDIR=~/.cache/antigen

# Do not keep in memory what files to check for configuration.
ANTIGEN_AUTO_CONFIG=false

# Load the framework.
source $ANTIGEN_INIT

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
command which asdf      >/dev/null 2>&1 && antigen bundle asdf
command which aws       >/dev/null 2>&1 && antigen bundle aws
command which docker    >/dev/null 2>&1 && antigen bundle docker
command which fzf       >/dev/null 2>&1 && antigen bundle fzf
command which gcloud    >/dev/null 2>&1 && antigen bundle gcloud
command which go        >/dev/null 2>&1 && antigen bundle golang
command which helm      >/dev/null 2>&1 && antigen bundle helm
command which kubectl   >/dev/null 2>&1 && antigen bundle kubectl && antigen bundle kube-ps1
command which minikube  >/dev/null 2>&1 && antigen bundle minikube
command which sudo      >/dev/null 2>&1 && antigen bundle sudo
command which terraform >/dev/null 2>&1 && antigen bundle terraform
command which vagrant   >/dev/null 2>&1 && antigen bundle vagrant && antigen bundle vagrant-prompt

# Other bundles.
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-history-substring-search
antigen bundle zsh-users/zsh-syntax-highlighting

# Load the theme.
antigen theme ${ANTIGEN_THEME:-gentoo}

# Tell Antigen that you're done.
antigen apply
