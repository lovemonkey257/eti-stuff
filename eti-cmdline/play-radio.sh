#! /bin/bash
#
# A quick and dirty script to create a very minimal DAB player
# including scanning.
#
# These work in UK. YMMV
#
#set -xv
if [ ! -x /usr/bin/jq ]; then
	echo "Need JQ to parse json files"
	exit 1
fi
PYTHON3=/usr/bin/python3
if [ ! -x $PYTHON3 ]; then
	echo "Python3 needs to be installed"
	exit 1
fi

ETI_CMD_LINE=${ETI_CMD_LINE:-./build/eti-cmdline-rtlsdr}
DEFAULT_BLOCKS=( 9C 9B 9A 8B 8A 7D 12D 12C 12B 12A 11D 11C 11B 11A 10D 10C 10B )
BLOCKS=${ETI_SCAN_BLOCKS:-${DEFAULT_BLOCKS[@]}}

cmd=$1
if [ "$cmd" == "play" ]; then
	if [ ! -x /usr/bin/dablin -a ! -x /usr/local/bin/dablin ]; then
		echo "Please install or build dablin"
		exit 1
	fi
	if [ ! -r station-list.json ]; then
		echo "No station list. Please scan first"
		exit 1
	fi
	shift
	station=$1
	details=$(jq -cr '. | keys[] as $k | select($k=="'"$station"'") | [.[$k].sid,.[$k].channel] | @csv' station-list.json | sed s/\"//g )
	sid=$( echo $details | cut -f1 -d, )
	ch=$( echo $details | cut -f2 -d, )
	if [ "$sid" != "" -a "$ch" != "" ]; then
		echo "Running: dablin -D eti-cmdline -d eti-cmdline-rtlsdr -c $ch -s $sid"
		dablin -D eti-cmdline -d $ETI_CMD_LINE -c $ch -s $sid
	else
		echo "Cannot find that station in the list"
		exit 1
	fi
	exit 0
fi

if [ "$cmd" == "list" ]; then
	[ ! -r station-list.json ] && echo "Need to scan first " && exit 1
	jq -cr '. | keys[]' station-list.json
	exit 0
fi

if [ "$cmd" == "scan" ]; then
	for block in ${BLOCKS[@]}
	do
	    echo "--------------------------------"
	    echo "Scanning $block"
	    echo "--------------------------------"
	    $ETI_CMD_LINE -J -x -C $block -D 10
	done
	echo "Compiling station list..."
	$PYTHON3 compile-station-list.py
	if [ -r station-list.json ]; then
		echo "Station list in station-list.json"
		num_stations=$(jq "keys[]" station-list.json | wc -l)
		echo "Found $num_stations stations"
		echo "Have fun"
		exit 0
	else
		echo "No stations to compile. Check reception. Check eti-cmdline ran?"
		exit 1
	fi
fi
cat <<USAGE
Toy radio player written in bash using dablin and eti-cmdline.
Needs dablin and jq to be installed to work

Will use "$ETI_CMD_LINE". Set env var ETI_CMD_LINE to change this e.g.

	ETI_CMD_LINE=/a/new/path/eti-cmdline-rtlsdr ./play-radio.sh scan

./play-radio.sh play <station> 	Plays station. Uses station-list.json from scan
                                Use the full station name and quotes if spaces in name
								e.g. "Magic Radio"

./play-radio.sh scan            Scans for stations. Creates station-list.json
./play-radio.sh list            List all the stations from last scan

To change the list of channels scanned use ETI_SCAN_BLOCKS to specify what
you want. Note this is a list. e.g

	ETI_SCAN_BLOCKS="10B 11C" ./play-radio.sh scan

Default block list is: ${DEFAULT_BLOCKS[*]}

If you performing multiple scans over different blocks the previous
ensemble*.json files are not deleted. When the final station list is
compiled it may contain stations you were not expecting.

USAGE
