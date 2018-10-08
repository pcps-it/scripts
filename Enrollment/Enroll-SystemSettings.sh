#!/bin/bash
#
#	Script Name: Enroll-SystemSettings.sh
#	Version: 1.0
#	Last Update: 2/12/2017
#	Requirements:
#
#	History
#		2/12/17
#			- Created file
#
##################################################
#!/bin/bash
jamfBinary="/usr/local/jamf/bin/jamf"
adUser="$4"
adPass="$5"

if [ -d "/Library/PCPS/enroll" ]; then
  rm -rf /Library/PCPS
fi

mkdir /Library/PCPS
mkdir /Library/PCPS/enroll

# Set time zone in preparation for AD binding
/usr/sbin/systemsetup -settimezone "America/New_York"
/usr/sbin/systemsetup -setusingnetworktime on
/usr/sbin/systemsetup -setnetworktimeserver "time.apple.com"

# Unbind from Active Directory
dsconfigad -remove -username $adUser -password $adPass

# Read /tmp/enroll-* files to prepare for binding
fileSchoolName="/tmp/enroll-SchoolName"
fileLocationNumber="/tmp/enroll-LocationNumber"
fileUserName="/tmp/enroll-UserName"
fileSAPNumber="/tmp/enroll-SAP"
fileEnvironmentLetter="/tmp/enroll-Environment"

schoolName=`awk '{print $1}' $fileSchoolName`
locationNumber=`awk '{print $1}' $fileLocationNumber`
userName=`awk '{print $1}' $fileUserName`
sapNumber=`awk '{print $1}' $fileSAPNumber`
environmentLetter=`awk '{print $1}' $fileEnvironmentLetter`

# Assign computer to user
$jamfBinary recon -endUsername $userName

# Assign asset tag to computer
$jamfBinary recon -assetTag $sapNumber

# Change ComputerName and HostName
echo "*** Setting the following paramters:"
echo "*** ComputerName: $schoolName - $sapNumber"
echo "*** HostName: $schoolName - $sapNumber"
/usr/sbin/scutil --set ComputerName "${schoolName} - ${sapNumber}"
/usr/sbin/scutil --set HostName "${schoolName} - ${sapNumber}"

# Change Local Host Name to district standard
computerID="L$locationNumber$environmentLetter-$sapNumber"
echo "Setting LocalHostName to district standard: $computerID" 2>&1
echo "40% Setting LocalHostName..." >&3
echo "Setting LocalHostName" 2>&1
/usr/sbin/scutil --set LocalHostName $computerID

# Force Bind
dsconfigad -add "polk-fl.net" -computer "${computerID}" -ou "CN=Computers,DC=polk-fl,DC=net" -username "${adUser}" -password "${adPass}" -force 2>&1
sleep 1

IS_BOUND=`dsconfigad -show | grep "Active Directory Domain"`
	if [ -n "${IS_BOUND}" ]; then
		echo "Bind successfuly."
		dsconfigad -mobile enable 2>&1
		dsconfigad -mobileconfirm disable 2>&1
		dsconfigad -localhome enable 2>&1
		dsconfigad -useuncpath disable 2>&1
		dsconfigad -protocol smb 2>&1
		dsconfigad -packetsign allow 2>&1
		dsconfigad -packetencrypt allow 2>&1
		dsconfigad -passinterval 0 2>&1

		# Enable network users
		GROUP_MEMBERS=`dscl /Local/Default -read /Groups/com.apple.access_loginwindow GroupMembers 2>/dev/null`
			NESTED_GROUPS=`dscl /Local/Default -read /Groups/com.apple.access_loginwindow NestedGroups 2>/dev/null`
		if [ -z "${GROUP_MEMBERS}" ] && [ -z "${NESTED_GROUPS}" ]; then
	    	dseditgroup -o edit -n /Local/Default -a netaccounts -t group com.apple.access_loginwindow 2>/dev/null
	  	fi

	else
		echo "Bind unsuccessful."
	fi

# Create Administrator account based on school location number
adminAccount="/Users/Administrator"

if [ -d "$adminAccount" ]; then
	echo "Administrator account exists. Ensuring correct password: EERS@$locationNumber"
	dscl . -passwd /Users/administrator "EERS@$locationNumber"
else
	echo "Administrator account does not exist. Creating one with password: EERS@$locationNumber"
	# Create Local Administrator based on Network Segment
	LastID=`dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1`
    NextID=$((LastID + 1))

	dscl . create /Users/administrator
	dscl . create /Users/administrator RealName "Administrator"
	dscl . create /Users/administrator hint "Location Number"
	dscl . create /Users/administrator picture "/Library/User Pictures/Animals/Eagle.tif"
	dscl . passwd /Users/administrator "EERS@$locationNumber"
	dscl . create /Users/administrator UniqueID $NextID
	dscl . create /Users/administrator PrimaryGroupID 80
	dscl . create /Users/administrator UserShell /bin/bash
	dscl . create /Users/administrator NFSHomeDirectory /Users/administrator
	dscl . -append /Groups/admin GroupMembership administrator
	cp -R /System/Library/User\ Template/English.lproj /Users/administrator
	chown -R administrator:staff /Users/administrator
fi



# Disable Time Machine's pop-up message whenever an external drive is plugged in
/usr/bin/defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Disable GateKeeper
spctl --master-disable

##################
# Disable iCloud #
##################
# Get OS Version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')
sw_vers=$(sw_vers -productVersion)

# For Future Users
for USER_TEMPLATE in "/System/Library/User Template"/*
	do
		/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool true
		/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
		/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
		/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
	done

# For Current Users
for USER_HOME in /Users/*
	do
		USER_UID=`basename "${USER_HOME}"`
		if [ ! "${USER_UID}" = "Shared" ]; then
			if [ ! -d "${USER_HOME}"/Library/Preferences ]; then
				mkdir -p "${USER_HOME}"/Library/Preferences
				chown "${USER_UID}" "${USER_HOME}"/Library
				chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
			fi
		if [ -d "${USER_HOME}"/Library/Preferences ]; then
			/usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool true
			/usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
			/usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
			/usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
			chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant.plist
		fi
	fi
	done

# Enable and configure Apple Remote Desktop
ARD="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
$ARD -configure -activate
$ARD -configure -access -on
$ARD -configure -allowAccessFor -specifiedUsers
$ARD -configure -access -on -users jamfadmin -privs -all
$ARD -configure -access -on -users administrator -privs -all



# Set diaplay to username and password text fields
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow EnableExternalAccounts -bool false


# Uninstall MSC if exists
if [ -d "/Applications/Managed Software Center.app" ]; then
	echo "75% Removing Managed Software Center components..." >&3
    $jamfBinary policy -event uninstallMunki
else
	echo "Managed Software Center not found. Skipping removal..."
fi

# Uninstall StarDeploy if exists
if [ -e "/Library/LaunchDaemons/sssd.plist" ]; then
  echo "78% Removing StarDeploy  components..." >&3
  launchctl unload -wF sssd.plist
  rm -R /usr/bin/sssd
  rm -R /Library/Application\ Support/sssd 
  rm -R /Library/PreferencePanes/sssd.prefPane 
  rm -R /Library/LaunchDaemons/sssd.plist
  rm -R /Library/Preferences/com.sssd.plist
  rm -R /private/var/db/sssd
  rm -R /Library/LaunchDaemons/com.stardeploy.sssd.plist
  rm -R /Library/Preferences/com.stardeploy.sssd.plist
  rm -R /Library/Application\ Support/StarDeploy
else
  echo "StarDeploy not found. Skipping removal..."
fi

touch /Library/PCPS/enroll/SystemSettings

exit 0