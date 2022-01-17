# Avoid autoupdating on every operation.
export HOMEBREW_NO_AUTO_UPDATE=1

# Opt out from analytics.
export HOMEBREW_NO_ANALYTICS=1

# Hardening.
export \
	HOMEBREW_CASK_OPTS="--require-sha" \
	HOMEBREW_NO_GITHUB_API=1 \
	HOMEBREW_NO_INSECURE_REDIRECT=1
