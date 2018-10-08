#!/bin/sh
#
#	Version: 1.0
#	Last Update: 6/26/2016
#	Requirements:
#		- None
#
#   Change Log:
##################################################

jamfBinary=`/usr/bin/which jamf`

if [ -e "/usr/local/bin/RemoteUpdateManager" ]; then
	echo "RemoteUpdateManager found."
else
	echo "RemoteUpdateManager not found. Installing..."
	$jamfBinary policy -event main-rum
fi