#!/bin/sh
#
#	Script Name: Enrollment - Configuration 2.9
#	Requirements:
#		- CocoaDialog
#		- Pashua
#
#	Change Log:
#		6/27/17
#			Total script rewrite streamlining enrollment process.
#		7/7/17
#			Added logic to only force unbind if the computer is aleady bound.
#		7/12/17
#			Adjusted workflow: Created a LaunchDaemon (/Library/LaunchDaemons/com.pcps.firstrun) to run on
#			15 second intervals until the user that is logged in is not a system-level user.
#		7/28/17
#			Added logic to install GUI tools. If it cannot install after 3 attempts, alert user and exit error 1.
#			Added logic to test if AD Bind actually succeeded. If not, it will retry until it is successful.
#		8/15/17
#			Fixed error with computers that were connected to internet via dongles
#		10/09/17
#			Added conditional logic for installs to make re-registering quicker.
#		10/18/17
#			Added command to enable managed users to add printers.
#		11/02/17
#			Added ability to opt-out of Apple software updates
#		7/16/18
#			Removed installation of iBoss web filter
#		8/13/18
#			Removed Adobe Flash installation to speed things up a bit.
#		8/24/18
#			Added the check for en7 on Ethernet adapaters.
#			Updated site location list from "itvdb.polk-fl.net" to "itv.polk-fl.net"
#		9/06/18
#			Created smarter loop-through of ethernet adapters to find the first adapter with an active network
#		9/26/18
#			Rewrote script to get ready for use with Enrollment 3.0
#			Added installs for NoMAD and NoMAD-Login
#			Removed all references to Active Directory
#			Sped registration process up by removing outdated items
#
#################################################################################################################

# Get currently logged in user
loggedInUser=$(stat -f%Su /dev/console)


# Check if currently logged in user is NOT a system-level user.
if [[ "$loggedInUser" == "_mbsetupuser" ]] || [[ "$loggedInUser" == "root" ]]; then
	echo "A system user is currently logged in: ${loggedInUser}. Exiting..."
    exit 0
fi


jamfBinary="/usr/local/jamf/bin/jamf"
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
MYDIR="/Library/PCPS/apps/"
resourcesDIR="/Library/PCPS/resources"
locationList="http://itv.polk-fl.net/downloads/enrollment/locations.txt"
apiUser="$4"
apiPass="$5"
baseURL="$6"


########################
# FUNCTION DEFINITIONS #
########################
# Define the registration screen function
function registerScreen {
db=""
while [ "$db" == "" ]; do	
	conf="
	# Window Title
	*.title = Mac Registration
	*.floating = 1
	*.y = 25

	# Computer image
	img.type = image
	img.maxwidth = 200
	img.relx = 65
	img.path = ${iconFullPath}

	# Serial Number
	serial.type = text
	serial.relx = 65
	serial.default = Computer Serial: ${serialNumber}

	# Textfield: Location
	location.type = textfield
	location.label = School or Department location number:
	location.width = 40
	location.mandatory = TRUE
	location.default = ${schoolNumber}

	# Textfield: sap
	sap.type = textfield
	sap.width = 75
	sap.label = Computer's eight-digit SAP:
	sap.placeholder = 50123456
	sap.mandatory = TRUE

	# Textfield: username
	clientUser.type = textfield
	clientUser.label = Assign computer to a user in the form of "john.smith":
	clientUser.placeholder = First.LastName
	clientUser.mandatory = TRUE

	# Radio: Computer's User Environment
	environment.type = radiobutton
	environment.label = Select the computer's primary user (students if unsure):
	environment.mandatory = TRUE
	environment.default = Students
	environment.option = Staff
	environment.option = Students

	# Additional Options
	options.type = text
	options.default = Additional Options
	options.rely = -15
	opAppleSWU.type = checkbox
	opAppleSWU.relx = 20
	opAppleSWU.default = 1
	opAppleSWU.label = Apply software updates

	# Cancel button
	cb.type = cancelbutton
	cb.disabled = 1

	# Register button
	db.type = defaultbutton
	db.label = Register
	db.tooltip = Register this computer.
	"
		
	if [ -d '/Volumes/Pashua/Pashua.app' ]; then
		# Looks like the Pashua disk image is mounted. Run from there.
		customLocation='/Volumes/Pashua'
	else
		# Search for Pashua in the standard locations
		customLocation=''
	fi

	pashua_run "$conf" "$customLocation"
done
}


################
#			   #
# SCRIPT START #
#			   #
################
# Install PCPS GUI Tools
# A notification is sent to the user stating enrollment will begin
# Check that GUI tools installed correctly.
# If not, attempt to install it two more times. If it still fails, alert user and exit enrollment.
ATTEMPTS=0
SUCCESS=
while [ -z "${SUCCESS}" ]; do
	if [ ${ATTEMPTS} -le 3 ]; then
		$jamfBinary policy -event main-pcps-gui

		if [ -e "/Applications/Pashua.app" ]; then
			SUCCESS="YES"
			sleep 1
		else
			sleep 1
			ATTEMPTS=`expr ${ATTEMPTS} + 1`
		fi

	else
		SUCCESS="NO"
		$CD msgbox --title "Mac Registration" --icon "caution" --text "Error 2" --informative-text "GUI tools failed to install correctly. Contact Justin Phillips at 647-4244 ext 517." --button1 "OK"
		exit 0
	fi
done


# Include pashua.sh to be able to use the 2 functions defined in that file
source "$MYDIR/pashua.sh"


# Checking for IP address
ipAddress=""
enAdapter=0
while [[ $ipAddress == "" ]]; do
	en=`ifconfig en${enAdapter} | grep "inet " | awk '{print $2}' | cut -c1-6`
	
	echo "variable: $en"
	
	if [[ $en == "" ]]; then
		enAdapter=$((enAdapter + 1))
		echo "new increment: $enAdapter"
	else
		ipAddress=$en
	fi
done

districtIP=`echo $ipAddress | cut -c1-5`
if [ $districtIP == 10.1. ]; then
	ipAddress=“”
fi


# Grab location number from hosted txt file
schoolNumber=`curl -s $locationList | grep "$ipAddress" | awk -F":" '{print $2}'`
schoolName=`curl -s $locationList | grep "$ipAddress" | awk -F":" '{print $3}'`


# Echo details about computer for future diagnostic purposes
echo " "
echo "--- AUTOMATICALLY GENERATED INFORMATION ---"
echo "Truncated IP Address: $ipAddress"
echo "School Number: $schoolNumber"
echo "School Name: $schoolName"
echo " "


# Get serial number
serialNumber=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Serial\ Number\ \(system\)/ {print $NF}'`


# Determine computer model to select correct image
computerModel=`system_profiler SPHardwareDataType | grep "Model Name:" | awk '{print $3}'`


# Create /Library/PCPS/resources directory if it does not exist
if [ ! -d "${resourcesDIR}" ]; then
	mkdir -p $resourcesDIR
fi


# Download image based on computer model. If model can't be determined, use the Self Service icon.
computerIcon=""
if [ "${computerModel}" == "iMac" ]; then
		curl -o ${resourcesDIR}/model-iMac.png http://itvdb.polk-fl.net/downloads/MacEnroller/images/model-iMac.png
		computerIcon="model-iMac.png"
	elif [ "${computerModel}" == "MacBook" ]; then
		curl -o ${resourcesDIR}/model-MacBook.png http://itvdb.polk-fl.net/downloads/MacEnroller/images/model-MacBook.png
		computerIcon="model-MacBook.png"
	elif [ "${computerModel}" == "Mac" ]; then
		curl -o ${resourcesDIR}/model-MacMini.png http://itvdb.polk-fl.net/downloads/MacEnroller/images/model-MacMini.png
		computerIcon="model-MacMini.png"
	elif [ "${computerModel}" == "MacPro" ]; then
		curl -o ${resourcesDIR}/model-MacPro.png http://itvdb.polk-fl.net/downloads/MacEnroller/images/model-MacPro.png
		computerIcon="model-MacPro.png"
	else
		curl -o ${resourcesDIR}/model-All.png http://itvdb.polk-fl.net/downloads/MacEnroller/images/model-All.png
		computerIcon="model-All.png"
fi


# Check if image downloaded correctly. If not, use the Self Service icon.
iconFullPath="/Library/PCPS/resources/${computerIcon}"
if [ ! -e "$iconFullPath" ]; then
	iconFullPath="/Applications/Self Service.app/Contents/resources/Self Service.icns"
fi


# Check one last time if currently logged in user is NOT a system-level user.
if [[ "$loggedInUser" == "_mbsetupuser" ]] || [[ "$loggedInUser" == "root" ]]; then
	echo "A system user is currently logged in: ${loggedInUser}. Exiting..."
	$CD msgbox --title "Mac Registration" --icon "caution" --text "Error 1" --informative-text "Mac Registration can only occur while logged in as a user." --button1 "OK"
    exit 0
fi


# Display Registration screen to user
registerScreen


# If user closes or quits Pashua, alert them that it cannot be skipped.
if [ "$db" == "0" ]; then
	$CD msgbox --title "Mac Registration" --icon "stop" --text "Registration cannot be skipped." --button1 "OK"
fi

# User clicked Register
if [ "$db" == "1" ]; then

	# Check if Location is numeric
	re='^[0-9]+$'
	if ! [[ "$location" =~ $re ]]; then
		while ! [[ "$location" =~ $re ]]; do
			$CD msgbox --title "Mac Registration" --icon "stop" --text "The Location must be a four-digit number." --button1 "OK"
			registerScreen
		done
	fi

	# Check if SAP is numeric
	if ! [[ "$sap" =~ $re ]]; then
		while ! [[ "$sap" =~ $re ]]; do
			$CD msgbox --title "Mac Registration" --icon "stop" --text "The SAP must be an eight-digit number." --button1 "OK"
			registerScreen
		done
	fi

	# Check if Location is 4 digits
	if [ "${#location}" -ge 5 ] || [ "${#location}" -le 3 ]; then
		while [ "${#location}" -ge 5 ] || [ "${#location}" -le 3 ]; do
			$CD msgbox --title "Mac Registration" --icon "stop" --text "The Location must be a four-digit number." --button1 "OK"
			registerScreen
		done
	fi

	# Check if SAP is 8 digits
	if [ "${#sap}" -ge 9 ] || [ "${#sap}" -le 7 ]; then
		while [ "${#sap}" -ge 9 ] || [ "${#sap}" -le 7 ]; do
			$CD msgbox --title "Mac Registration" --icon "stop" --text "The SAP must be an eight-digit number." --button1 "OK"
			registerScreen
		done
	fi

	locationFilter=`curl -s $locationList | grep "$location"`

	if [ "$locationFilter" == "" ]; then
		while [ "$locationFilter" == "" ]; do
			$CD msgbox --title "Mac Registration" --icon "stop" --text "This is not a known location number." --informative-text "if you feel this is a mistake, contact Justin Phillips at 647-4244 ext 517 before proceeding." --button1 "OK"
			registerScreen
		done
	else
		locationNumber=`echo $locationFilter | awk -F":" '{print $2}'`
		locationName=`echo $locationFilter | awk -F":" '{print $3}'`
	fi

	# Display variables for future diagnostic purposes
	echo " "
	echo "--- USER PROVIDED INFORMATION ---"
	echo "Location Number: $locationNumber"
	echo "Location Name: $locationName"
	echo "SAP: $sap"
	echo "Client: $clientUser"
	echo "Environment: $environment"
	echo " "


	# Setup CocoaDialog's progressbar
	# create a named pipe
	rm -f /tmp/hpipe
	mkfifo /tmp/hpipe

	# create a background job which takes its input from the named pipe
	$CD progressbar --title "Mac Registration" < /tmp/hpipe &

	# associate file descriptor 3 with that pipe and send a character through the pipe
	exec 3<> /tmp/hpipe
	echo -n . >&3


	# Set time zone
	echo "7% Setting Time Zone..." >&3
	echo "Setting Time Zone..." 2>&1
	/usr/sbin/systemsetup -settimezone "America/New_York"
	/usr/sbin/systemsetup -setusingnetworktime on
	/usr/sbin/systemsetup -setnetworktimeserver "time.apple.com"
	ntpdate -u time.apple.com
	sleep 1


	# Check if already bound. If yes, unbind
	echo "14% Unbinding from Active Directory..." >&3
	echo "Unbinding from Active Directory..." 2>&1
	bindingCheck=`dsconfigad -show | grep "Active Directory Domain"`
	if [[ -z $bindingCheck ]]; then
		echo "Not bound. Skipping unbind..."
	else
		echo "Computer already bound. Unbinding..."
		dsconfigad -force -remove -u bogusUsername -p bogusPassword
	fi


	# Change ComputerName, HostName, and LocalHostName
	echo "21% Setting computer name..." >&3
	echo "Setting computer name..." 2>&1
	/usr/sbin/scutil --set ComputerName "${locationName} - ${sap}"
	/usr/sbin/scutil --set HostName "${locationName} - ${sap}"
	/usr/sbin/scutil --set LocalHostName "${locationName} - ${sap}"
	sleep 1


	# Create Administrator account
	osvers=$(sw_vers -productVersion | awk -F. '{print $2}')
	if [ "$osvers" == "14" ]; then
		echo "OS Mojave, skipping Administrator account creation..."
	else
		echo "28% Creating local Administrator account..." >&3
		echo "Creating local Administrator account..." 2>&1
		adminAccount="/Users/administrator"

		if [ -d "$adminAccount" ]; then
			echo "Administrator account exists. Ensuring correct password: EERS@$location"
			dscl . -passwd /Users/administrator "EERS@$location"
		else
			echo "Administrator account does not exist. Creating one with password: EERS@$location"
			# Create Local Administrator based on Network Segment
			LastID=`dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1`
		    NextID=$((LastID + 1))

			dscl . create /Users/administrator
			dscl . create /Users/administrator RealName "Administrator"
			dscl . create /Users/administrator hint "Location"
			dscl . create /Users/administrator picture "/Library/User Pictures/Animals/Eagle.tif"
			dscl . passwd /Users/administrator "EERS@$location"
			dscl . create /Users/administrator UniqueID $NextID
			dscl . create /Users/administrator PrimaryGroupID 80
			dscl . create /Users/administrator UserShell /bin/bash
			dscl . create /Users/administrator NFSHomeDirectory /Users/administrator
			dscl . -append /Groups/admin GroupMembership administrator
			cp -R /System/Library/User\ Template/English.lproj /Users/administrator
			chown -R administrator:staff /Users/administrator
		fi
	fi


	# Install Nomad and Nomad Logo
	echo "35% Configuring: Computer login settings..." >&3
	echo "Configuring: Computer login settings..." 2>&1
	$jamfBinary policy -event main-nomad
	
	# Download PCPS wallpaper
	curl -o ${resourcesDIR}/wallpaper-pcps.jpg http://itv.polk-fl.net/downloads/MacEnroller/images/wallpaper-pcps.jpg


	# Disable Time Machine's pop-up message whenever an external drive is plugged in
	echo "42% Configuring: Time Machine settings..." >&3
	echo "Configuring: Time Machine settings..." 2>&1
	/usr/bin/defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true


	# Disable GateKeeper
	echo "49% Configuring: GateKeeper settings..." >&3
	spctl --master-disable


	# Enable and configure Apple Remote Desktop
	echo "56% Configuring: Apple Remote Desktop settings..." >&3
	ARD="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
	$ARD -configure -activate
	$ARD -configure -access -on
	$ARD -configure -allowAccessFor -specifiedUsers
	$ARD -configure -access -on -users jamfadmin -privs -all
	$ARD -configure -access -on -users administrator -privs -all


	echo "63% Configuring: Printer settings..." >&3
	/usr/sbin/dseditgroup -o edit -n /Local/Default -a everyone -t group lpadmin


	echo "70% Configuring: System Settings..." >&3
	# ENABLE FINDER SCROLL BARS
	# For future users
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

	 # For current users
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
	
	
	# Update computer record in Jamf
	echo "77% Updating: Computer record in Jamf..." >&3
	JSSHostname="$baseURL/JSSResource/computers/serialnumber/$serialNumber/subset/extensionattributes"
	XMLTOWRITE="<computer><extension_attributes><extension_attribute><name>Primary User</name><value>$environment</value></extension_attribute></extension_attributes></computer>"
	curl -s -k -u $apiUser:$apiPass -X PUT -H "Content-Type: text/xml" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$XMLTOWRITE" $JSSHostname


	# Apple Software Updates
	if [[ "$opAppleSWU" == "1" ]]; then
		echo "84% Installing: Apple software updates... This may take some time..." >&3
		softwareupdate -i -a
	fi


	# Assign user and SAP to computer record in Jamf
	echo "100% Registration complete! Your computer will restart in a moment..." >&3
	$jamfBinary recon -endUsername $clientUser -assetTag $sap


	# Remove LaunchDaemon
	rm /Library/LaunchDaemons/com.pcps.firstrun.plist	


	exec 3>&-
	rm -f /tmp/hpipe


	# Force computer restart
	sudo shutdown -r now
fi