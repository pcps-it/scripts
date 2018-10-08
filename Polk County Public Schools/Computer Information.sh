#!/bin/bash
jamfServer="$4"
apiUser="$5"
apiPass="$6"

# Enable and configure Apple Remote Desktop
ARD="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
$ARD -configure -activate
$ARD -configure -access -on
$ARD -configure -allowAccessFor -specifiedUsers
$ARD -configure -access -on -users jamfadmin -privs -all
$ARD -configure -access -on -users administrator -privs -all

## General section #####
# Display computer name
computerName=`/usr/sbin/scutil --get ComputerName`

# Display serial number
serialNumber=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/grep "Serial Number" | /usr/bin/awk -F ": " '{ print $2 }'`

# Display SAP
assetTag=$( curl -s -k -u $apiUser:$apiPass -H "Content-Type: application/xml" "${jamfServer}/JSSResource/computers/serialnumber/${serialNumber}" | awk -F'<asset_tag>|</asset_tag>' '{print $2}' )

if [ "$assetTag" == "" ]; then
	assetTag="Unknown"
fi

# Display uptime
runCommand=`/usr/bin/uptime | /usr/bin/awk -F "(up |, [0-9] users)" '{ print $2 }'`
if [[ "$runCommand" = *day* ]] || [[ "$runCommand" = *sec* ]] || [[ "$runCommand" = *min* ]] ; then
	upTime="$runCommand"
else
	upTime="$runCommand hrs/min"
fi


## Network section #####
# Display active network services and IP Addresses
networkServices=`/usr/sbin/networksetup -listallnetworkservices | /usr/bin/grep -v asterisk`

while IFS= read aService
do
	activePort=`/usr/sbin/networksetup -getinfo "$aService" | /usr/bin/grep "IP address" | /usr/bin/grep -v "IPv6"`
	if [ "$activePort" != "" ] && [ "$activeServices" != "" ]; then
		activeServices="$activeServices\n$aService $activePort"
	elif [ "$activePort" != "" ] && [ "$activeServices" = "" ]; then
		activeServices="$aService $activePort"
	fi
done <<< "$networkServices"

activeServices=`echo "$activeServices" | /usr/bin/sed '/^$/d'`


# Display Wi-Fi SSID
model=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/grep 'Model Name'`

if [[ "$model" = *Book* ]]; then
	SSID=`/usr/sbin/networksetup -getairportnetwork en0 | /usr/bin/awk -F ": " '{ print $2 }'`
else
	SSID=`/usr/sbin/networksetup -getairportnetwork en1 | /usr/bin/awk -F ": " '{ print $2 }'`
fi


## Active Directory section #####
# Display Active Directory binding
adCheck=`/usr/sbin/dsconfigad -show | /usr/bin/grep "Directory Domain" | /usr/bin/awk -F "= " '{ print $2 }'`

if [ "$adCheck" = polk-fl.net ]; then
	AD="Yes"
else
	AD="No"	
fi

# Test Active Directory binding
connectionTest=$( /usr/bin/dscl "/Active Directory/POLK-FL/All Domains" read /Users )

if [ "$connectionTest" = "name: dsRecTypeStandard:Users" ]; then
	testAD="Success"
else
	testAD="Fail"	
fi



## Hardware/Software section #####
# Display free space
volumeName=`diskutil info / | grep "Volume Name" | cut -c 31-`
freeSpace=`/usr/sbin/diskutil info "$volumeName" | /usr/bin/grep  -E 'Free Space|Available Space' | /usr/bin/awk -F ":\s*" '{ print $2 }' | awk -F "(" '{ print $1 }' | xargs`
freePercentage=$( /usr/sbin/diskutil info "$volumeName" | /usr/bin/grep -E 'Free Space|Available Space' | /usr/bin/awk -F "(\\\(|\\\))" '{ print $6 }' )

# Display operating system
operatingSystem=`/usr/bin/sw_vers -productVersion`

# Display battery cycle count
batteryCycleCount=`/usr/sbin/ioreg -r -c AppleSmartBattery | /usr/bin/awk '$1=="\"CycleCount\"" {print $3}'`


## Management section #####
# Jamf Agent Info
jamfAgent=`/usr/bin/which jamf`
if [ "$jamfAgent" != "" ]; then
	jamfVersion=`defaults read /Library/Application\ Support/JAMF/Jamf.app/Contents/Info.plist CFBundleShortVersionString`
	jamfURL=`defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url`
	jamfCommCheck=`jamf checkJSSConnection > /dev/null; echo $?`
	
	if [[ "$jamfCommCheck" -eq 0 ]]; then
		jamfConnection="Success"
	elif [[ "$jss_comm_chk" -gt 0 ]]; then
		jamfConnection="Failed"
	fi
fi


##### Format information #####
displayInfo="-------------------------------------------------
COMPUTER
-------------------------------------------------
Name: $computerName
SAP: $assetTag
Serial Number: $serialNumber
Up Time: $upTime

-------------------------------------------------
NETWORK
-------------------------------------------------
Wi-Fi: $SSID
$activeServices

-------------------------------------------------
ACTIVE DIRECTORY
-------------------------------------------------
Bound to AD: $AD
Connection Test: $testAD

-------------------------------------------------
HARDWARE/SOFTWARE
-------------------------------------------------
Operating System: $operatingSystem
Disk Space: $freeSpace free ($freePercentage available)
Battery Cycle Count: $batteryCycleCount

-------------------------------------------------
MANAGEMENT
-------------------------------------------------
Version: $jamfVersion
URL: $jamfURL
Connection Test: $jamfConnection
"


## Display information to end user #####
runCommand="button returned of (display dialog \"$displayInfo\" with title \"Computer Information\" with icon file posix file \"/System/Library/CoreServices/Finder.app/Contents/Resources/Finder.icns\" buttons {\"OK\"} default button {\"OK\"})"

clickedButton=$( /usr/bin/osascript -e "$runCommand" )

exit 0