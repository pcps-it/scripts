#!/bin/bash
#
#	Script Name: ITV File Server.sh
#	Version: 1.3
#	Last Update: 10/12/2016
#	Requirements:
#		- CocoaDialog
#		- Pashua
#
#	History
#		12/18/16
#			- Drastically simplified script and removed superfluous features.
#			- Removed jamf binary mount command as it was hitting AD servers twice, resulting in locked out Users.
#
##################################################
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
jamfBinary="/usr/local/jamf/bin/jamf"
serverAddress="$4"
MYDIR="/Library/PCPS/apps/"

# Include pashua.sh to be able to use the 2 functions defined in that file
source "$MYDIR/pashua.sh"

username=""
user=""
password=""
pass=""
credCheckbox="0"
credFile="/Library/PCPS/data/.fileserver"
shareFriendlyName=""
shareName=""

if [ -d "/Volumes/Family Engagement" ]; then
	diskutil unmount "/Volumes/Family Engagement"
fi

if [ -d "/Volumes/Teacher Share" ]; then
	diskutil unmount "/Volumes/Teacher Share"
fi

if [ -d "/Volumes/home" ]; then
	diskutil unmount "/Volumes/home"
fi


# Check for credentials file in /Library/PCPS/data/.fileserver
if [ -e "$credFile" ]; then
	user=`awk '{print $1}' $credFile`
	pass=`awk '{print $2}' $credFile`
	credCheckbox="1"
fi

# Username and password prompt
conf="
# Window Title
*.title = ITV File Server


# Username: Textfield
username.type = textfield
username.label = Username:
username.placeholder = First.LastName
username.tooltip = Use First.LastName for authentication.
username.default = "$user"
username.mandatory = Yes

# Password: Password
password.type = password
password.label = Password:
password.default = "$pass"
password.mandatory = Yes

# Share; Combobox
share.type = combobox
share.label = Server Share:
share.completion = 2
share.mandatory = TRUE
share.placeholder = Select a share...
share.option = Family Engagement
share.option = Teacher Share
share.option = Video Awards Submission

# Checkbox: Remember credentials
credentials.type = checkbox
credentials.label = Remember these credentials on this computer.
credentials.default = "$credCheckbox"

# Cancel button
cb.type = cancelbutton
cb.tooltip = Cancel

db.type = defaultbutton
db.label = Connect
"

if [ -d '/Volumes/Pashua/Pashua.app' ]; then
	# Looks like the Pashua disk image is mounted. Run from there.
	customLocation='/Volumes/Pashua'
else
	# Search for Pashua in the standard locations
	customLocation=''
fi

pashua_run "$conf" "$customLocation"

# Return values
if [ "$db" == "1" ]; then
	if [ "$credentials" == "1" ]; then
		if [ ! -d "/Library/PCPS/data" ]; then
			mkdir /Library/PCPS/data
			echo -e "$username $password" > $credFile
		else
			echo -e "$username $password" > $credFile
		fi
	fi

	if [ "$credentials" == "0" ]; then
		rm $credFile
	fi


	# Determine which share was selected in combobox
	if [ "$share" == "Family Engagement" ]; then
		shareName="Family Engagement"
		shareFriendlyName="Family Engagement"
	elif [ "$share" == "Teacher Share" ]; then
		shareName="Teacher Share"
		shareFriendlyName="Teacher Share"
	elif [ "$share" == "Video Awards Submission" ]; then
		shareName="home"
		shareFriendlyName="Video Awards Submission"
	fi

	rm -f /tmp/hpipe
	mkfifo /tmp/hpipe
	$CD progressbar --icon fileserver --indeterminate --float --title "ITV File Server" --text "Connecting to ${shareFriendlyName}..." < /tmp/hpipe &

	# associate file descriptor 3 with that pipe and send a character through the pipe
	exec 3<> /tmp/hpipe
	echo -n . >&3

	# Mount share
	mount_script=`/usr/bin/osascript  > /dev/null << EOT
    tell application "Finder"
    mount volume "smb://${username}:${password}@${serverAddress}/${shareName}"
    end tell
	EOT`
	
	# Tturn off the progress bar by closing file descriptor 3
	exec 3>&-

	# Wait for all background jobs to exit
	wait
	rm -f /tmp/hpipe

	# Check for successful mount; notify user if unsuccessful
	if [ -d "/Volumes/$shareName" ]; then
		open /Volumes/"$shareName"
	else
		$CD msgbox --float --no-newline \
		--icon stop \
		--title "ITV File Server" \
		--text "Could not connect to: $shareFriendlyName" \
		--informative-text "Your username or password is incorrect. Please try again." \
		--button1 "OK"
	fi
else
	echo "User Cancelled. Exiting..."
	exit 0
fi
exit 0