#!/bin/bash
jamfBinary="/usr/local/jamf/bin/jamf"
debugLog="/var/tmp/depNotifyDebug.log"
registrationPlist="/var/tmp/DEPNotify.plist"
bomFile="/var/tmp/com.depnotify.registration.done"
prefPlist="Libray/Preferences/menu.nomad.DEPNotify.plist"


# Read user's responses from DEPNotify
serialNumber=`defaults read $registrationPlist "Computer Serial"`
user=`defaults read $registrationPlist "Assign to User"`
computerRole=`defaults read $registrationPlist "Computer Role"`
sapNumber=`defaults read $registrationPlist "Computer SAP Number"`
location=`defaults read $registrationPlist "Location"`
locationNumber=`echo $location | tail -c 5 | cut -c -4`
locationName=`echo $location | sed 's/.\{7\}$//'`

# Configure Apple Remote Desktop and activate service
ARD="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
$ARD -configure -activate
$ARD -configure -access -on
$ARD -configure -allowAccessFor -specifiedUsers
$ARD -configure -access -on -users jamfadmin -privs -all
$ARD -configure -access -on -users administrator -privs -all

# Set Time Zone
/usr/sbin/systemsetup -settimezone "America/New_York"
/usr/sbin/systemsetup -setusingnetworktime on
/usr/sbin/systemsetup -setnetworktimeserver "time.apple.com"
ntpdate -u time.apple.com

# Unbind from Active Directory
bindingCheck=`dsconfigad -show | grep "Active Directory Domain"`
if [[ -z $bindingCheck ]]; then
	echo "Not bound. Skipping unbind..."
else
	dsconfigad -force -remove -u bogusUsername -p bogusPassword
fi

# Rename computer to district standard
/usr/sbin/scutil --set ComputerName "${locationName} - ${sapNumber}"
/usr/sbin/scutil --set HostName "${locationName} - ${sapNumber}"
/usr/sbin/scutil --set LocalHostName "${locationName} - ${sapNumber}"

# Disable Time Machine's pop-up message whenever an external drive is plugged in
/usr/bin/defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Disable GateKeeper
spctl --master-disable

# Add all current and future users to printer group
/usr/sbin/dseditgroup -o edit -n /Local/Default -a everyone -t group lpadmin

# Disable iCloud Setup screen
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')
sw_vers=$(sw_vers -productVersion)

for USER_TEMPLATE in "/System/Library/User Template"/*
	do
		/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool true
		/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
		/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
		/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
	done

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

# Disable Diagnostic Reports screen
# Define variables
SUBMIT_TO_APPLE=NO
SUBMIT_TO_APP_DEVELOPERS=NO

PlistBuddy="/usr/libexec/PlistBuddy"
os_rev_major=`/usr/bin/sw_vers -productVersion | awk -F "." '{ print $2 }'`
if [ $os_rev_major -ge 10 ]; then
  CRASHREPORTER_SUPPORT="/Library/Application Support/CrashReporter"
  CRASHREPORTER_DIAG_PLIST="${CRASHREPORTER_SUPPORT}/DiagnosticMessagesHistory.plist"

  if [ ! -d "${CRASHREPORTER_SUPPORT}" ]; then
    mkdir "${CRASHREPORTER_SUPPORT}"
    chmod 775 "${CRASHREPORTER_SUPPORT}"
    chown root:admin "${CRASHREPORTER_SUPPORT}"
  fi

  for key in AutoSubmit AutoSubmitVersion ThirdPartyDataSubmit ThirdPartyDataSubmitVersion; do
    $PlistBuddy -c "Delete :$key" "${CRASHREPORTER_DIAG_PLIST}" 2> /dev/null
  done

  $PlistBuddy -c "Add :AutoSubmit bool ${SUBMIT_TO_APPLE}" "${CRASHREPORTER_DIAG_PLIST}"
  $PlistBuddy -c "Add :AutoSubmitVersion integer 4" "${CRASHREPORTER_DIAG_PLIST}"
  $PlistBuddy -c "Add :ThirdPartyDataSubmit bool ${SUBMIT_TO_APP_DEVELOPERS}" "${CRASHREPORTER_DIAG_PLIST}"
  $PlistBuddy -c "Add :ThirdPartyDataSubmitVersion integer 4" "${CRASHREPORTER_DIAG_PLIST}"
fi

# Enable system-wide scroll bars
for USER_TEMPLATE in "/System/Library/User Template"/*
  do
     if [ ! -d "${USER_TEMPLATE}"/Library/Preferences ]
      then
        mkdir -p "${USER_TEMPLATE}"/Library/Preferences
     fi
     if [ ! -d "${USER_TEMPLATE}"/Library/Preferences/ByHost ]
      then
        mkdir -p "${USER_TEMPLATE}"/Library/Preferences/ByHost
     fi
     if [ -d "${USER_TEMPLATE}"/Library/Preferences/ByHost ]
      then
        /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/.GlobalPreferences AppleShowScrollBars -string Always
     fi
  done

 for USER_HOME in /Users/*
  do
    USER_UID=`basename "${USER_HOME}"`
    if [ ! "${USER_UID}" = "Shared" ] 
     then 
      if [ ! -d "${USER_HOME}"/Library/Preferences ]
       then
        mkdir -p "${USER_HOME}"/Library/Preferences
        chown "${USER_UID}" "${USER_HOME}"/Library
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
      fi
      if [ ! -d "${USER_HOME}"/Library/Preferences/ByHost ]
       then
        mkdir -p "${USER_HOME}"/Library/Preferences/ByHost
        chown "${USER_UID}" "${USER_HOME}"/Library
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
	chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/ByHost
      fi
      if [ -d "${USER_HOME}"/Library/Preferences/ByHost ]
       then
        /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/.GlobalPreferences AppleShowScrollBars -string Always
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/.GlobalPreferences.*
      fi
    fi
  done
exit 0