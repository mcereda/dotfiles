{{- if eq .chezmoi.os "darwin" }}

{{-   if stat "/Applications/SnowflakeCLI.app" -}}

export PATH=/Applications/SnowflakeCLI.app/Contents/MacOS/:$PATH

{{-   end }}

{{- end }}
