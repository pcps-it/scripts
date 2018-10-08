#!/bin/sh
#
#	Script Name: Testing Environment Setter.sh
#	Version: 1.0
#	Last Update: 11/8/2016
#	Requirements:
#		- Pashua
#
##################################################
MYDIR="/Library/PCPS/apps/"

# Include pashua.sh to be able to use the 2 functions defined in that file
source "$MYDIR/pashua.sh"

loggedInUser="$3"
echo "User: $loggedInUser"

conf="
# Window Title
*.title = Testing Environment Setter
*.floating = 1

# Radio Button: State
state.type = radiobutton
state.label = Turn the testing environment on or off:
state.default = 
state.mandatory = TRUE
state.option = On
state.option = Off

# Text: Settings
settings.type = text
settings.default = The following settings will be updated:
settings.rely = -20


setting1.type = text
setting1.default = - Expose
setting1.rely = -20

setting2.type = text
setting2.default = - Spaces
setting2.rely = -20

setting3.type = text
setting3.default = - Function Keys


# Cancel button
cb.type = cancelbutton

# Bind button
db.type = defaultbutton
db.label = Set
"
	
if [ -d '/Volumes/Pashua/Pashua.app' ]; then
	# Looks like the Pashua disk image is mounted. Run from there.
	customLocation='/Volumes/Pashua'
else
	# Search for Pashua in the standard locations
	customLocation=''
fi

pashua_run "$conf" "$customLocation"

if [ "${state}" == "On" ]; then
	echo "Turning testing environment on..."
	sudo -u ${loggedInUser} defaults write com.apple.dock mcx-expose-disabled -bool TRUE && killall Dock
	
elif [ "${state}" == "Off" ]; then
	echo "Turning testing environment off..."
	sudo -u ${loggedInUser} defaults delete com.apple.dock mcx-expose-disabled && killall Dock
fi
exit 0