BREW_PREFIX="${BREW_PREFIX:-$(brew --prefix)}"
BREW_CASKROOM="${BREW_CASKROOM:-$(brew --caskroom)}"

# Avoid autoupdating on every operation.
export HOMEBREW_NO_AUTO_UPDATE="${HOMEBREW_NO_AUTO_UPDATE:-1}"

# Opt out from analytics.
export HOMEBREW_NO_ANALYTICS="${HOMEBREW_NO_ANALYTICS:-1}"

# Hardening.
export \
	HOMEBREW_CASK_OPTS="${HOMEBREW_CASK_OPTS} --require-sha" \
	HOMEBREW_NO_GITHUB_API="${HOMEBREW_NO_GITHUB_API:-1}" \
	HOMEBREW_NO_INSECURE_REDIRECT="${HOMEBREW_NO_INSECURE_REDIRECT:-1}"

# Prioritize kegs.
for keg in ${KEGS[@]}
do
	path=(
		"${BREW_PREFIX}/opt/${keg}/bin"
		${path[@]}
	)
done
unset keg KEGS
