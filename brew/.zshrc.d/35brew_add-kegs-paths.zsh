# Prioritize kegs
for keg in ${KEGS[@]}
do
	path=(
		"${BREW_PREFIX}/opt/${keg}/bin"
		${path[@]}
	)
done
unset KEG KEGS
