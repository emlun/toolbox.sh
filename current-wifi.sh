#!/bin/bash
# Print the currently active netctl profile, or (none) if none is active.

search() {
    wpa_cli -i wlan0 status | grep 'ssid'
}

if search &> /dev/null; then
    search | sed -n 's/^ssid=//p'
else
    echo '(none)'
fi
