alias gpg-decrypt-all='find . -type f -name "*.gpg" -print -exec gpg --batch --decrypt-files --yes "{}" +'
