#!/bin/bash
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
logFile="/var/log/com.pcps.general.log"

# Check for and/or create logFile
if [ ! -f "${logFile}" ]; then
    # logFile not found; Create logFile
    /usr/bin/touch "${logFile}"
fi

# Setup function
function ScriptLog() { # Re-direct logging to the log file ...

    exec 3>&1 4>&2        # Save standard output and standard error
    exec 1>>"${logFile}"    # Redirect standard output to logFile
    exec 2>>"${logFile}"    # Redirect standard error to logFile

    NOW=`date +%Y-%m-%d\ %H:%M:%S`    
    /bin/echo "${NOW} FixLoginKeychain" " ${1}" >> ${logFile}

}

# Get currently logged in user
loggedInUser=$(stat -f%Su /dev/console)
ScriptLog "Currently logged in user: $loggedInUser."

# Use padlock icon from macOS
icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/LockedIcon.icns"

# Display password dialog
rv=`$CD secure-standard-inputbox \
	--float \
	--title "Fix Login KeyChain" \
	--icon-file "$icon" \
	--informative-text "Enter your current login password:"`

# Grab user input details
userSelection=`echo $rv | awk '{print $1}'`
newPassword=`echo $rv | awk '{print $2}'`

# Get user's Login KeyChain
userKeychain=`su $loggedInUser -c "security list-keychains" | grep login | sed -e 's/\"//g' | sed -e 's/\// /g' | awk '{print $NF}'`
ScriptLog "User's keychain: $userKeychain"

# Delete user's Login KeyChain
su $loggedInUser -c "security delete-keychain $userKeychain"
ScriptLog "Keychain deleted."

# Create the new login keychain
expect <<- DONE
	set timeout -1
	spawn su $loggedInUser -c "security create-keychain login.keychain-db"

	# Look for prompt
	expect "*?chain:*"

	# send user entered password
	send "$newPassword\n"
	expect "*?chain:*"
	send "$newPassword\r"
	expect EOF
DONE
ScriptLog "New Keychain created."

# Set as user's default KeyChain
su $loggedInUser -c "security default-keychain -s login.keychain-db"
ScriptLog "New Keychain set as default."