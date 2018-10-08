#!/bin/bash

serverName="$4"
username="$5"
userPassword="$6"
shareOneName="$7"
shareTwoName="$8"
shareThreeName="$9"



if [ -z "$username" ]; then	# Checks if the variable is empty (user running script from Self Service)
    username="$USER"
fi

sleep 1

# Mount the Share One
if [ "$7" != "" ]; then
	mount_script=`/usr/bin/osascript > /dev/null << EOT
	    tell application "Finder"
	        activate
	        mount volume "smb://${username}:${userPassword}@${serverName}/${shareOneName}"
	    end tell
	EOT`
fi

sleep 1

# Mount the Share Two
if [ "$8" != "" ]; then
	mount_script=`/usr/bin/osascript > /dev/null << EOT
	    tell application "Finder"
	        activate
	        mount volume "smb://${username}:${userPassword}@${serverName}/${shareTwoName}"
	    end tell
	EOT`
fi

sleep 1

# Mount the Share Three
if [ "$9" != "" ]; then
	mount_script=`/usr/bin/osascript > /dev/null << EOT
	    tell application "Finder"
	        activate
	        mount volume "smb://${username}:${userPassword}@${serverName}/${shareThreeName}"
	    end tell
	EOT`
fi


exit 0