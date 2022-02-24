alias az-login-again-if-expired='az account show >/dev/null || az login --use-device-code'
az-reset () {
	az account clear
	az login --use-device-code
	az account set --subscription ${AZURE_SUBSCRIPTION}
}
