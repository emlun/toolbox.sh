#!/bin/bash
# Print the currently active netctl profile, or (none) if none is active.

INTERFACE=${1:-wlan0}

search() {
    wpa_cli -i "${INTERFACE}" status | grep 'ssid'
}

if search &> /dev/null; then
    search | sed -n 's/^ssid=//p'
else
    echo '(none)'
fi
