alias gauth="gcloud auth login ${GCLOUD_USER:-$(git config --get user.email)}"
alias gauth-apps='gauth && gcloud auth application-default login'
alias gauth-apps-cli='gauth-apps --no-launch-browser'

alias gke-context-add='gcloud container clusters get-credentials'
alias gke-cluster-ls='gcloud container clusters list'
alias gke-cluster-list='gke-cluster-ls'

alias gcloud-project-change="gcloud config set project $@"
