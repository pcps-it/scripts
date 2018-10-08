#!/bin/bash
dockutil="/usr/local/bin/dockutil"
loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
loggedInUserHome="/Users/$loggedInUser"

echo "Currently logged in user: $loggedInUser"

# Download Wallpaper
curl -o /Library/PCPS/resources/kms-wallpaper.png http://itvdb.polk-fl.net/downloads/schools/kms-wallpaper.png

# Setup Dock
if [[ ! -e $dockutil ]]; then
	echo "DockUtil not found. Installing..."
	jamf policy -event main-gui
fi

$dockutil --remove all --allhomes --no-restart
$dockutil --add "/Applications/Google Chrome.app" --allhomes --no-restart
$dockutil --add "/Applications/Final Cut Pro.app" --allhomes --no-restart
$dockutil --add "/Applications/Motion.app" --allhomes --no-restart
$dockutil --add "/Applications/StoryboardFountain.app" --allhomes --no-restart
$dockutil --add "/Applications/Adobe Photoshop CC 2017/Adobe Photoshop CC 2017.app" --allhomes --no-restart
$dockutil --add "/Applications/Adobe Illustrator CC 2017/Adobe Illustrator.app" --allhomes --no-restart
$dockutil --add "/Applications/Microsoft Word.app" --allhomes --no-restart
$dockutil --add "/Applications/Microsoft Outlook.app" --allhomes --no-restart
$dockutil --add "/Applications/Microsoft OneNote.app" --allhomes --no-restart
$dockutil --add "/Applications" --view grid --display folder --allhomes --no-restart
$dockutil --add '~/Downloads' --view grid --display folder --allhomes 

# Applying Read and Execute-only permissions to user's Desktop, Documents, Pictures, Music, and Movies folders.

chmod -R a=rx ${loggedInUserHome}/Desktop
chown -R nobody ${loggedInUserHome}/Desktop
chmod -R a=rx ${loggedInUserHome}/Documents
chown -R nobody ${loggedInUserHome}/Documents
chmod -R a=rx ${loggedInUserHome}/Pictures
chown -R nobody ${loggedInUserHome}/Pictures
chmod -R a=rx ${loggedInUserHome}/Music
chown -R nobody ${loggedInUserHome}/Music

if [ ! -d "$loggedInUserHome/Movies/Motion Templates.localized" ]; then
    mkdir $loggedInUserHome/Movies/Motion\ Templates.localized
    mkdir $loggedInUserHome/Movies/Motion\ Templates.localized/Compositions.localized
    mkdir $loggedInUserHome/Movies/Motion\ Templates.localized/Effects.localized
    mkdir $loggedInUserHome/Movies/Motion\ Templates.localized/Generators.localized
    mkdir $loggedInUserHome/Movies/Motion\ Templates.localized/Titles.localized
    mkdir $loggedInUserHome/Movies/Motion\ Templates.localized/Transitions.localized
fi


#defaults write com.apple.mouse enableSecondaryClick 1  

#defaults write com.apple.Dock position-immutable -bool yes
#defaults write com.apple.Dock size-immutable -bool yes
#defaults write com.apple.Dock contents-immutable -bool yes
#killall Dock


exit 0