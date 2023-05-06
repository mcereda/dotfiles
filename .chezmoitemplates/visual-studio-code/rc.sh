vscode-bootstrap-extensions () {
	[[ $DEBUG ]] && set -x

	local VSCODE_EXTENSIONS_LIST_FILE="${VSCODE_EXTENSIONS_LIST:-$HOME/.vscode/extensions.txt}"

	# --force updates to the latest version
	cat "$VSCODE_EXTENSIONS_LIST_FILE" \
	| xargs -I{} -r code --install-extension "{}" --force

	[[ $DEBUG ]] && set +x
}
vscode-remove-ignored-extensions () {
	[[ $DEBUG ]] && set -x

	{{- $vscodeSettingsFile := "" }}
	{{- if eq .chezmoi.os "darwin" }}
	{{-   $vscodeSettingsFile = joinPath "$HOME" "Library" "Application Support" "Code" "User" "settings.json" }}
	{{- else if eq .chezmoi.os "linux" }}
	{{-   $vscodeSettingsFile = joinPath "$HOME" ".config" "Code" "User" "settings.json" }}
	{{- end }}
	local VSCODE_SETTINGS_FILE="${VSCODE_SETTINGS_FILE:-{{ $vscodeSettingsFile }}}"

	code --list-extensions \
	| xargs -I{} grep {} $VSCODE_SETTINGS_FILE \
	| cut -d '"' -f 2 \
	| xargs -n1 -r code --uninstall-extension

	[[ $DEBUG ]] && set +x
}
vscode-use-marketplace-for-extensions () {
	[[ $DEBUG ]] && set -x

	local VSCODE_PRODUCT_FILE="${VSCODE_PRODUCT_FILE:-{{ ternary (joinPath "/Applications" "Visual Studio Code.app" "Contents" "Resources" "app" "product.json") (joinPath "/usr" "lib" "code" "product.json") (eq .chezmoi.os "darwin") }}}"
	local TEMP_FILE="${TEMP_FILE:-$(mktemp /tmp/product.json.XXX)}"

	if [[ ! -f "$VSCODE_PRODUCT_FILE" ]]
	then
		echo "ERROR: file '$VSCODE_PRODUCT_FILE' not found"
		return 1
	fi

	sudo cp "$VSCODE_PRODUCT_FILE" "${VSCODE_PRODUCT_FILE}.bak"
	jq '.extensionsGallery = {
			serviceUrl: "https://marketplace.visualstudio.com/_apis/public/gallery",
			cacheUrl: "https://vscode.blob.core.windows.net/gallery/index",
			itemUrl: "https://marketplace.visualstudio.com/items"
		}' \
		"$VSCODE_PRODUCT_FILE" \
	| sudo sponge "$VSCODE_PRODUCT_FILE"

	[[ $DEBUG ]] && sudo jq '.' "$VSCODE_PRODUCT_FILE"

	[[ $DEBUG ]] && set +x
}
