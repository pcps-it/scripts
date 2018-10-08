#!/bin/sh
#
# Name: remove-local-users
#
# Purpose: Removes all local accounts except for the following:
#	- All system-level accounts
#	- Administrator
#	- jamfadmin
#

jamfHelper='/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper'
dockutil="/usr/local/bin/dockutil"


# Find list of all local users except those mentioned above (mobile accounts have UID of over 1000).
users=`dscl . list /Users UniqueID | awk '$2 < 1000 {print $1}' | grep -v "_" | grep -v "administrator" | grep -v "daemon" | grep -v "jamfadmin" | grep -v "casperscreensharing" | grep -v "nobody" | grep -v "root" | grep -v "Guest"`

if [ "$users" == "" ]; then
	echo "No local users to archive. Exiting..."
	exit 0
else
	# Get currently logged in user
	loggedInUser=`stat -f%Su /dev/console`

	# Check if that user is a network account or local
	accountStatus=`dscl . read /Users/$loggedInUser OriginalNodeName 2>/dev/null`

	# Message Settings
	dialogIcon="/Applications/Self Service.app/Contents/Resources/Self Service.icns"
	msgTitle="User Accounts"
	msgHeading="Important Notice"
	msgDescription=""

	#display different messages
	if [ "$accountStatus" == "" ]; then
		# User is a local account
		msgDescription="As per the D.O.E., we are archiving your local user accounts and you will no longer be able to log in with them. You can restore any needed files from \"/Users/Deleted Users\" until September 5th.
		
After September 5th, this directory will be removed.
		
This computer will log out once this process has completed and you will need to log in with PCPS network credentials."
	else
		# User is a network account
		msgDescription="As per the D.O.E., we are archiving your local user accounts and you will no longer be able to log in with them. You can restore any needed files from \"/Users/Deleted Users\" until September 5th.
		
After September 5th, this directory will be removed.
		
Your account is already a network account and this process will not change how you log in.

This window will disappear once this conversion has completed."
	fi


	# Display customized message
	"${jamfHelper}" -lockHUD -windowType utility -icon "$dialogIcon" \
		-title "$msgTitle" \
		-heading "$msgHeading" -alignHeading center \
		-description "$msgDescription" &



	# Go through list and archive, then delete each account
	for i in $users; do
	        /usr/local/jamf/bin/jamf deleteAccount -username $i
	        rm -Rf /Users/$i
	done

	/usr/local/jamf/bin/jamf recon

	killall jamfHelper 2> /dev/null

	sudo pkill loginwindow

fi

exit 0
