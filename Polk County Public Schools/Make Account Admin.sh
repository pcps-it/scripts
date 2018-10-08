#!/bin/bash
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
jamfHelper="/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
cdExists=""
loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

if [ ! -e $CD ]; then
	echo "CocoaDialog does not exist. Installing..."
	jamf policy -event main-gui
fi


# Elevate privs for currently logged in user
echo "Currently logged in user: $loggedInUser"
dscl . -append /Groups/admin GroupMembership $loggedInUser
chown -R administrator:staff /Users/$loggedInUser


# Alert user
rv=`$CD yesno-msgbox --no-cancel --no-newline \
--title "Polk County Public Schools" \
--icon "notice" \
--text "Complete." \
--informative-text "This account is now an administrator, but for the changes to take effect, the computer must be restarted.

Restart now?"`

if [ "$rv" == "1" ]; then
	#sudo shutdown -r now
else
	exit 0
fi


exit 0