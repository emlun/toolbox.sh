#!/bin/bash
# Wraps md5sum and allows specification of the correct md5sum
# immediately on the command line.

if [[ $# < 2 ]]; then
	echo "Usage: md5chk <file> <md5 string>"
	exit 1
fi

echo "Correct sum: $2"
sum=$(md5sum $1 | cut -d \  -f 1)
echo "File sum:    $sum"

if [[ $sum == $2 ]]; then
	echo "Match!"
	exit 0
else
	echo "Sums do not match!"
	exit 2
fi

