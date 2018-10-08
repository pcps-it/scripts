#!/bin/sh
dockutil="/usr/local/bin/dockutil"
loggedInUser="$3"
loggedInUserHome="/Users/$loggedInUser"

echo "Current logged in user: $loggedInUser"
echo "User home: $loggedInUserHome"

# Setup Dock
if [[ ! -e $dockutil ]]; then
	echo "DockUtil not found. Installing..."
	jamf policy -event main-gui
fi

$dockutil --remove all --allhomes --no-restart
$dockutil --add "/Applications/Safari.app" --allhomes --position 1 --no-restart
$dockutil --add "/Applications/iTunes.app" --allhomes --position 2 --no-restart
$dockutil --add "/Applications/Final Cut Pro.app" --allhomes --position 3 --no-restart
$dockutil --add "/Applications/Microsoft Word.app" --allhomes --position 4 --no-restart
$dockutil --add "/Applications/Motion.app" --allhomes --position 5 --no-restart
$dockutil --add "/Applications/Adobe Photoshop CC 2017/Adobe Photoshop CC 2017.app" --allhomes --position 6

defaults write com.apple.mouse enableSecondaryClick 1


# Setup symlinks to /Users/Motion Templates/
motionTemplates="/Users/Shared/Motion Templates/Compositions/"

if [ -d "$motionTemplates" ]; then
	# create an array with all the filer/dir inside ~/myDir
	arr=(/Users/Shared/Motion\ Templates/Compositions/*)

	# iterate through array using a counter
	for ((i=0; i<${#arr[@]}; i++)); do
	    #do something to each element of array
	    ln -s "${arr[$i]}" $loggedInUserHome/Movies/Motion\ Templates.localized/Compositions.localized
	done
fi

	

exit 0