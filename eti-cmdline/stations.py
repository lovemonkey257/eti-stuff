#! /usr/bin/python


## TODO:
## Cmd line options
## - create|find|play

import os
import json

stations=dict()

obj = os.scandir()
for entry in obj :
    if entry.is_dir() or entry.is_file():
        if entry.name.startswith("ensemble-ch-") and entry.name.endswith(".json"):
            with open(entry.name, 'r') as jfile:
                data = json.load(jfile)
                for s,sid in data['stations'].items():
                    if s not in stations:
                        stations[s]={ 'sid':sid, 'ensemble':data['ensemble'], 'channel':data['channel'] }
                    else:
                        stations[s + " " + data['ensemble'] ]={ 'sid':sid, 'ensemble':data['ensemble'], 'channel':data['channel'] }
obj.close()
with open("station-list.json","w") as s:
    json.dump(stations,s)

# dablin -D eti-cmdline -d eti-cmdline-rtlsdr -c 11D -s 0xd911
