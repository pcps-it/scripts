#!/bin/bash
dockutil="/usr/local/bin/dockutil"
loggedInUser=$(stat -f "%Su" /dev/console)
loggedInUserHome="/Users/$loggedInUser"

echo "Current logged in user: $loggedInUser"

# Setup Dock
if [[ ! -e $dockutil ]]; then
	echo "DockUtil not found. Installing..."
	jamf policy -event main-gui
fi

$dockutil --remove all --allhomes --no-restart
$dockutil --add "/Applications/Safari.app" --allhomes --position 1 --no-restart
$dockutil --add "/Applications/Google Chrome.app" --allhomes --position 2 --no-restart
$dockutil --add "/Applications/Adobe Premiere Pro CC 2017/Adobe Premiere Pro CC 2017.app" --allhomes --position 3 --no-restart
$dockutil --add '~/Downloads' --view grid --display folder

exit 0