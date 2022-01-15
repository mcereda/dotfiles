alias boinc-down="sudo systemctl stop boinc-client.service && sudo cpupower frequency-set --governor schedutil"
alias boinc-up="sudo cpupower frequency-set --governor ondemand && echo 1 | sudo tee /sys/devices/system/cpu/cpufreq/ondemand/ignore_nice_load && sudo systemctl start boinc-client.service"
