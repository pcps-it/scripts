#!/bin/bash
#
#	Script Name: ADelete File or Directory.sh
#	Version: 1.2
#	Last Update: 11/7/2016
#	Requirements:
#		None
#
##################################################
jamfBinary="/usr/local/jamf/bin/jamf"
filePath="/Applications/Final Cut Pro X/Final Cut Pro.app"

if [ -d "$filePath" ]; then
	echo "${filePath} found. Deleting..."
	rm -rf "$filePath"
	
	echo "Deleted. Sending updated inventory..."
	jamf recon
else
	echo "File or directory not found. Deletion skipped."
fi

exit 0