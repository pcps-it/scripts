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
$dockutil --add "/Applications/Self Service.app" --allhomes --position 1 --no-restart
$dockutil --add "/Applications/iTunes.app" --allhomes --position 2 --no-restart
$dockutil --add "/Applications/Microsoft Word.app" --allhomes --position 3 --no-restart
$dockutil --add "/Applications/Final Cut Pro.app" --allhomes --position 4 --no-restart
$dockutil --add "/Applications/Safari.app" --allhomes --position 5 --no-restart
$dockutil --add "/Applications/QuickTime Player.app" --allhomes --position 6 --no-restart
$dockutil --add "/Applications/Adobe Photoshop CC 2018/Adobe Photoshop CC 2018.app" --allhomes --position 7 --no-restart
$dockutil --add "/Applications/Adobe Premiere Pro CC 2018/Adobe Premiere Pro CC 2018.app" --allhomes --position 8 --no-restart
$dockutil --add "/Applications/Adobe After Effects CC 2018/Adobe After Effects CC 2018.app" --allhomes --position 9

defaults write com.apple.mouse enableSecondaryClick 1

exit 0