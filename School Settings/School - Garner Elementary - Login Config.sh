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
$dockutil --add "/Applications/Self Service.app" --allhomes --position 2 --no-restart
$dockutil --add "/Applications/Microsoft PowerPoint.app" --allhomes --position 3 --no-restart
$dockutil --add "/Applications/Microsoft Word.app" --allhomes --position 4 --no-restart
$dockutil --add "/Applications/FSASecureBrowser.app" --allhomes --position 5 --no-restart
$dockutil --add https://hosted368.renlearn.com/69995/ --label 'Renaissance Learning' --allhomes --position 6

	

exit 0