#!/bin/bash
#
#	Script Name: Auninstall - Munki.sh
#	Version: 1.0
#	Last Update: 10/12/2016
#	Requirements:
#		- DockUtil
#
##################################################

dockutil="/usr/local/bin/dockutil"

$dockutil --remove 'Managed Software Center' --allhomes

launchctl unload /Library/LaunchDaemons/com.googlecode.munki.*

rm -rf "/Applications/Utilities/Managed Software Update.app"

rm -f /Library/LaunchDaemons/com.googlecode.munki.*
rm -f /Library/LaunchAgents/com.googlecode.munki.*
rm -rf "/Library/Managed Installs"
rm -rf /usr/local/munki
rm /etc/paths.d/munki

pkgutil --forget com.googlecode.munki.admin
pkgutil --forget com.googlecode.munki.app
pkgutil --forget com.googlecode.munki.core
pkgutil --forget com.googlecode.munki.launchd

exit 0