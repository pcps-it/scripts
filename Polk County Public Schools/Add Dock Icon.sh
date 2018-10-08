#!/bin/sh
appPath="$4"
appName="$5"

# Check for / create logFile
logFile="/var/log/com.pcps.general.log"
if [ ! -f "${logFile}" ]; then
    # logFile not found; Create logFile
    /usr/bin/touch "${logFile}"
fi

function ScriptLog() { # Re-direct logging to the log file ...

    exec 3>&1 4>&2        # Save standard output and standard error
    exec 1>>"${logFile}"    # Redirect standard output to logFile
    exec 2>>"${logFile}"    # Redirect standard error to logFile

    NOW=`date +%Y-%m-%d\ %H:%M:%S`    
    /bin/echo "${NOW} *Dock Icon*" " ${1}" >> ${logFile}

}

# Define variables
dockutil="/usr/local/bin/dockutil"
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
jhPath="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
icon="/Applications/Self Service.app/Contents/Resources/Self Service.icns"

## Get information about the logged in user
loggedInUser=`stat -f%Su /dev/console`
userHomePath=`/usr/bin/dscl . -read /Users/$loggedInUser NFSHomeDirectory | awk '{print $2}'`

## Various message strings that we may use
msgText="Installation complete"
msgInfoText=""

# Log setup information
ScriptLog " "
ScriptLog "*** Add Dock Icon ***"
ScriptLog "Application Path: ${appPath}/${appName}"
ScriptLog "User Home: ${userHomePath}/${loggedInUser}"

# Check if App installed correctly
if [[ ! -d "${appPath}/${appName}.app" ]]; then
    ScriptLog "The application at ${appPath}/${appName}.app isn't on this Mac: Error 1"
	$CD msgbox --float \
	--title "Self Service" \
	--icon "stop" \
	--text "Error 1" \
	--informative-text "$appName did not install correctly. Please try again later." \
	--button1 "Quit"
    exit 1
fi

## Creating variables based on assigned parameters
ScriptLog "Checking if App is already in Dock..."
dockIconCheck=`/usr/bin/defaults read $userHomePath/Library/Preferences/com.apple.dock | grep "file-label.*${appName}"`
ScriptLog "Result: $dockIconCheck"

if [ "$dockIconCheck" != "" ]; then
	ScriptLog "App already exists in Dock. Silently exiting..."
	exit 0
else
	ScriptLog "App does not exist in Dock. Alerting user..."
	rv=`$CD msgbox --timeout 30 --timeout-format " " --icon-file "$icon" \
		--title "Self Service" \
		--text "Installation complete." \
		--informative-text "The $appName icon is not in your Dock. Would you like to add it now?" \
		--button1 "   Yes   " \
		--button2 "   No   " \
		--cancel "button2"`

	ScriptLog "User response: $rv"
	if [[ "$rv" == "2" ]]; then
		ScriptLog "Will not add Dock icon. Silently exiting..."
		exit 0
	else
		ScriptLog "Adding $appName to Dock..."
		$dockutil --add "${appPath}/${appName}.app" --allhomes
	fi

fi

exit 0