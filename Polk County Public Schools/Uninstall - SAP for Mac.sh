#!/bin/sh
dockutil="/usr/local/bin/dockutil"
jamfBinary="/usr/local/jamf/bin/jamf"

if [[ -d "/Applications/SAP Clients" ]]; then
	rm -rf "/Applications/SAP Clients"
fi

exit 0