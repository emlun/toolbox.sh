#!/bin/bash

if ! hash ibam; then
  echo "ibam not found!"
  exit 1
fi

# Hours and minutes left
time=$(ibam | grep Battery | grep -oE "([[:digit:]]+:?)+" | cut -d : -f 1-2)

if [[ "$time" == "" ]]; then
  # Charge time left
  time=$(ibam | grep Charge | grep -oE "([[:digit:]]+:?)+" | cut -d : -f 1-2)
  time="CHRG $time"
fi

# Percentage left
percent=$(ibam --percentbattery | grep percentage | grep -oE '[[:digit:]]+')

echo "$time ($percent%)"
