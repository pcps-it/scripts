#!/bin/bash

# Get currently logged in user
loggedInUser=$(stat -f%Su /dev/console)

# Check if currently logged in user is NOT a system-level user.
if [[ "$loggedInUser" == "_mbsetupuser" ]] || [[ "$loggedInUser" == "root" ]]; then
	echo "Currently logged in user: ${loggedInUser}. Exiting..."
    exit 0
fi

/usr/bin/open http://itvdb.polk-fl.net/downloads/enrollment/complete/
sleep 1

launchctl unload -w /Library/LaunchDaemons/com.pcps.enrollcomplete.plist
sleep 1

rm  /Library/LaunchDaemons/com.pcps.enrollcomplete.plist
exit 0