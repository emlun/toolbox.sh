#!/bin/bash
# Print the SSID of the currently active wifi connection, or (none).

INTERFACE=${1:-wlan0}

search() {
  wpa_cli -i "${INTERFACE}" status | grep 'ssid'
}

if search &> /dev/null; then
  search | sed -n 's/^ssid=//p'
else
  echo '(none)'
fi
