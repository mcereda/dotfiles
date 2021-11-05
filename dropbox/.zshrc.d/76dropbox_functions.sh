alias dropbox-update='dropbox-install'
dropbox-install () {
	# https://www.dropbox.com/install-linux
	[[ ${DEBUG} ]] && set -o xtrace

	DROPBOX_archive="/tmp/dropbox_daemon.tar.gz"
	DROPBOX_retries="3"
	DROPBOX_url="http://www.getdropbox.com/download?plat=lnx.x86_64"

	# download daemon
	echo "  downloading archive…"
	curl $DROPBOX_url \
		--continue-at - \
		--location \
		--output $DROPBOX_archive \
		--retry $DROPBOX_retries \
		--silent --show-error

	# install daemon
	[[ -d "${HOME}/.dropbox-dist" ]] && echo "  removing old executables…" && rm -r "${HOME}/.dropbox-dist"
	echo "  unarchiving tarball…"
	tar zxf $DROPBOX_archive -C $HOME

	# cleaning
	rm $DROPBOX_archive

	[[ ${DEBUG} ]] && set +o xtrace
}
dropbox-install-control-script () {
	# https://www.dropbox.com/install-linux
	[[ ${DEBUG} ]] && set -o xtrace

	DROPBOX_retries=3
	DROPBOX_script_download_path="/tmp/dropbox.py"
	DROPBOX_script_installation_path="/usr/local/bin/dropbox"
	DROPBOX_script_url="https://www.dropbox.com/download?dl=packages/dropbox.py"

	echo "  downloading script…"
	curl $DROPBOX_script_url \
		--continue-at - \
		--location \
		--output $DROPBOX_script_download_path \
		--retry $DROPBOX_retries \
		--silent --show-error

	echo "  installing script…"
	sudo install $DROPBOX_script_download_path $DROPBOX_script_installation_path

	[[ ${DEBUG} ]] && set +o xtrace
}
