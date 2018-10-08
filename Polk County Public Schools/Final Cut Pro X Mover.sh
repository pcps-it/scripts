#!/bin/bash
#
#
#	Version: 1.0
#	Process Timeline:
#		- Check if FCP X exists in /Applications/Final Cut Pro X/
#			-Yes
#				- Delete folder
#
####################################################################################################
jamfBinary=`/usr/bin/which jamf`
jamfHelper='/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper'
dockutil="/usr/local/bin/dockutil"


# Message Settings
dialogIcon="/Applications/Self Service.app/Contents/Resources/Self Service.icns"
msgTitle="Apple Pro Application Update"
msgDescription="Please wait while Final Cut Pro X and Motion are updated.

This could take several minutes."


"${jamfHelper}" -lockHUD -windowType utility -icon "$dialogIcon" \
	-title "$msgTitle" \
	-description "$msgDescription" &

processFCP=`pgrep "Final Cut Pro"`
processMotion=`pgrep "Motion"`

if [ ! -z "$processFCP" ]; then
	killall "Final Cut Pro"
	sleep 1
fi

if [ ! -z "$processMotion" ]; then
	killall "Motion"
	sleep 1
fi

if [ -e "/Applications/Final Cut Pro X" ]; then
	rm -rf "/Applications/Final Cut Pro X"
	$dockutil --remove "Final Cut Pro" --allhomes --no-restart
	$dockutil --remove "Motion" --allhomes --no-restart
	$dockutil --remove "Compressor" --allhomes
	sleep 1
fi

if [ -e "/Applications/Final Cut Pro.app" ]; then
	fcpVersion=$( /usr/bin/defaults read "/Applications/Final Cut Pro.app/Contents/Info.plist" CFBundleVersion )
	if [ "$fcpVersion" == "7.0.3" ]; then
		mkdir "/Applications/Final Cut Studio"
		sleep 1

		mv "/Applications/Final Cut Pro.app" "/Applications/Final Cut Studio/"
		mv "/Applications/Apple Qadministrator.app" "/Applications/Final Cut Studio/"
		mv "/Applications/Apple Qmaster.app" "/Applications/Final Cut Studio/"

		$dockutil --add "/Applications/Final Cut Studio/Final Cut Pro.app" --allhomes
	fi

	compressorVersion=$( /usr/bin/defaults read "/Applications/Compressor.app/Contents/Info.plist" CFBundleVersion )
	if [ "$compressorVersion" == "3.5.3" ]; then
		mv "/Applications/Compressor.app" "/Applications/Final Cut Studio/"
	fi
fi


jamf policy -event main-fcpx
jamf policy -event main-motion


killall jamfHelper 2> /dev/null

exit 0