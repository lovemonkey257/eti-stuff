#! /bin/bash
#
station=$1
deets=$(jq -cr '. | keys[] as $k | select($k=="'"$station"'") | [.[$k].sid,.[$k].channel] | @csv' station-list.json | sed s/\"//g )
sid=$( echo $deets | cut -f1 -d, )
ch=$( echo $deets | cut -f2 -d, )
echo $ch $sid
if [ "$sid" != "" -a "$ch" != "" ]; then
	echo dablin -D eti-cmdline -d eti-cmdline-rtlsdr -c $ch -s $sid
	dablin -D eti-cmdline -d eti-cmdline-rtlsdr -c $ch -s $sid
fi
exit 1
