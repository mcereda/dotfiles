alias python-upgrade-all='pip install --requirement <(pip freeze | sed "s/==/>=/") --upgrade'
