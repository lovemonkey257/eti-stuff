#! /bin/bash
# https://www.radiodns.uk/multiplexes.json
#
#

curl https://www.radiodns.uk/multiplexes.json > multiplexes.json
if [ -s multiplexes.json ]; then
	echo "Getting DAB block info from www.radiodns.uk..."
	blocks=$(jq -r ".[].block" multiplexes.json | sort -r | uniq)
else
	echo "Using default block settings. May be incomplete"
	blocks=$(jq -r ".uk[]" default-multiplexes.json | sort -r | uniq)
fi
for block in $blocks
do
    echo "--------------------------------"
    echo "Scanning $block"
    echo "--------------------------------"
    eti-cmdline-rtlsdr -J -x -C $block -D 10
done
echo "Compiling station list..."
python stations.py
echo "Station list in station-list.json"
num_stations=$(jq "keys[]" station-list.json | wc -l)
echo "Found $num_stations"
echo "Have fun"
