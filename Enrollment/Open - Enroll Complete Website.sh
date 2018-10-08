#!/bin/bash

/usr/bin/open http://itvdb.polk-fl.net/downloads/enrollment/complete/

launchctl unload -w /Library/LaunchAgents/com.pcps.enrollcomplete.plist

rm  /Library/LaunchAgents/com.pcps.enrollcomplete.plist

exit 0