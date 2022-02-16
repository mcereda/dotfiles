alias python-upgrade-all='pip install --no-cache-dir --requirement <(pip freeze | sed "s/==/>=/") --upgrade'
alias python-user-upgrade-all='python-upgrade-all --user'
