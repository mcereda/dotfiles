{{- if eq .chezmoi.os "darwin" }}

alias citrix-disable-autostart='\
	find /Library/LaunchAgents /Library/LaunchDaemons -iname "*.citrix.*.plist" \
	-exec sudo -p "sudo password: " mv -fv {} {}.backup ";"'

{{- end }}
