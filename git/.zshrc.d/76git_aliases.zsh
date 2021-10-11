alias gbda-all='for repo in $(find ~/Repositories -type d -name ".git" -exec dirname {} ";"); do cd $repo && gbda && cd -; done'
