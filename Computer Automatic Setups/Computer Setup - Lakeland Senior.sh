#!/bin/bash
#
#	Script Name: Computer Setup - Lakeland Senior.sh
#	Version: 1.1
#	Last Update: 1/23/2017
#	Requirements:
#		DockUtil
#
#	Change History
#		1/23/2017
#			- Removed command to update Adobe apps after installation as it took too long.
#
##################################################
jamfBinary="/usr/local/jamf/bin/jamf"
dockutil="/usr/local/bin/dockutil"

if [ -d "/Users/televisionproduction" ]; then
	echo "Television Production account already exists. Skipping creation."
else
	# Create Television Production account with no password
	LastID=`dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1`
	NextID=$((LastID + 1))

	dscl . create /Users/televisionproduction
	dscl . create /Users/televisionproduction RealName "Television Production"
	dscl . create /Users/televisionproduction hint ""
	dscl . create /Users/televisionproduction picture "/Library/User Pictures/Animals/Eagle.tif"
	dscl . passwd /Users/televisionproduction ""
	dscl . create /Users/televisionproduction UniqueID $NextID
	dscl . create /Users/televisionproduction PrimaryGroupID 80
	dscl . create /Users/televisionproduction UserShell /bin/bash
	dscl . create /Users/televisionproduction NFSHomeDirectory /Users/televisionproduction
	dscl . -append /Groups/admin GroupMembership televisionproduction
	cp -R /System/Library/User\ Template/English.lproj /Users/televisionproduction
	chown -R televisionproduction:staff /Users/televisionproduction

	# Sleep for 10 seconds to allow home directories to be created
	sleep 10

	# Set account to automatically log in on next reboot
	defaults write /Library/Preferences/com.apple.loginwindow "autoLoginUser" 'televisionproduction'
fi


# Remove everything from the Dock and add the basics
$dockutil --remove all --allhomes --no-restart
$dockutil --add "/Applications/Self Service.app" --allhomes --no-restart
$dockutil --add "/Applications/Safari.app" --allhomes

# Start software installations
# GOOGLE
$jamfBinary policy -event main-chrome

# APPLE
$jamfBinary policy -event main-fcpx
$jamfBinary policy -event main-motion

# ADOBE
$jamfBinary policy -event main-premiere
$jamfBinary policy -event main-aftereffects
$jamfBinary policy -event main-photoshop
$jamfBinary policy -event main-illustrator
$jamfBinary policy -event main-indesign
$jamfBinary policy -event main-audition
$jamfBinary policy -event main-acrobatdc

# MISC
$jamfBinary policy -event main-celtx
$jamfBinary policy -event main-handbrake
$jamfBinary policy -event main-vlc

exit 0