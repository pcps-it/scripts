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
softwareVersion="0"

if [ -e "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app" ]; then
	echo "MAU found."
else
	echo "MAU not found. Installing..."
	$jamfBinary policy -event main-mau
fi