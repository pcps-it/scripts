#!/bin/bash
#
#	Script Name: Enrollment - Configuration 3.0
#	Requirements:
#		- DEPNotify
#
#	Change Log:
#		9/21/18
#			- Initial creation
#		9/22/18
#			- Added numbered error handling messages to user
#
#############################################################

## Get currently logged in user
loggedInUser=$(stat -f%Su /dev/console)

## Loop through script until the logged in user is not a system-level user
scriptRetries=0
while [[ "$loggedInUser" == "_mbsetupuser" ]] || [[ "$loggedInUser" == "root" ]]; do
	echo "A system user is currently logged in: ${loggedInUser}. Retrying in 3 seconds..."
	sleep 3
	
	scriptRetries=$((scriptRetries + 1))
	echo "Enrollment retry: $scriptRetries"
	loggedInUser=$(stat -f%Su /dev/console)
	
	if [[ $scriptRetries = 10 ]]; then
		echo "Maximum amount of retries reached. Exiting..."
		$jamfHelper -windowType hud -title Mac Registration -heading Error: 1 -alignHeading left -description "Cannot run Mac Registration during Apple Setup Assistant and will now exit. Please re-run the Mac Registration from Self Service once you are logged into a user's account." -alignDescription left -button1 Quit -defaultButton 0 -lockHUD
		exit 0
	fi
	
done

## Display current user
echo "Currently logged in user: $loggedInUser"

## Master variable declarations
jamfBinary=/usr/local/jamf/bin/jamf
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
resourcesDIR="/Library/PCPS/resources"
depLog=/var/tmp/depnotify.log
registrationPlist="/var/tmp/DEPNotify.plist"
bomFile="/var/tmp/com.depnotify.registration.done"
prefPlist="Libray/Preferences/menu.nomad.DEPNotify.plist"
aduser="$4"
adpass="$5"
AD_DOMAIN="polk-fl.net"
COMPUTERS_OU="CN=Computers,DC=polk-fl,DC=net"

## Create /Library/PCPS/resources directory, if it does not exist
if [ ! -d "${resourcesDIR}" ]; then
	mkdir -p $resourcesDIR
fi

## Download PCPS logo, if it does not exist
if [ ! -e "${resourcesDIR}/logo-pcps.png" ]; then
	curl -o ${resourcesDIR}/logo-pcps.png http://itv.polk-fl.net/downloads/enrollment/images/logo-pcps.png

	while [ ! "${resourcesDIR}/logo-pcps.png" ]; do
		sleep 1
	done
fi

## Install DEPNotify
if [ ! -e "/Applications/DEPNotify.app" ]; then
	$jamfBinary policy -event main-depnotify
fi

if [ ! -e "/Applications/DEPNotify.app" ]; then
	$jamfHelper -windowType hud -title Mac Registration -heading Error: 2 -alignHeading left -description "Could not download required software! Make sure the computer is connected to the internet and re-run the Mac Registration policy in Self Service."  -alignDescription left -icon /Library/PCPS/resources/logo-pcps.png -button1 Quit -defaultButton 0 -lockHUD
	exit 0
fi

## Quit DEPNotify in case it is running
echo "Command: Quit" >> $depLog

## Remove any DEPNotify related files so that new paramters can be set
rm -rf $depLog
rm -rf $registrationPlist
rm -rf $bomFile
rm "/Users/${loggedInUser}/${prefPlist}"

## Double-check we're on the Desktop by checking for Finder and Dock
if pgrep -x "Finder" && pgrep -x "Dock"; then
	## Kill any installer process running
	killall Installer

	## Configure the main DEPNotify screen
	echo "Command: WindowStyle: NotMovable" >> $depLog
	echo "Command: WindowStyle: ActivateOnStep" >> $depLog
	echo "Command: WindowTitle: PCPS Mac Registration" >> $depLog
	echo "Command: Image: ${resourcesDIR}/logo-pcps.png" >> $depLog
	echo "Command: MainTitle: Click Register to begin." >> $depLog
	echo "Command: MainText: " >> $depLog
	echo "Status: " >> $depLog
	echo "Command: Determinate: 13" >> $depLog
	echo "Command: ContinueButtonRegister: Register" >> $depLog

	## Define School and Department location list
	locationList=(
		"Acceleration & Innovation - 9107"
"Alta Vista Elementary - 0331"
"Alturas Elementary - 1041"
"Apple Bistro - 9406"
"Auburndale Central Elementary - 0851"
"Auburndale Senior - 0811"
"Bartow Academy - 0941"
"Bartow Middle - 0931"
"Bartow Senior - 0901"
"Bartow IB - 0901"
"Bartow Warehouse - 9422"
"Ben Hill Griffin Elementary - 1921"
"Bethune Academy - 0391"
"Bill Duncan Opportunity Ctr - 2001"
"Blake Academy - 1861"
"Boone Middle - 0321"
"Boswell Elementary - 1811"
"Brigham Academy - 0531"
"Business Process Support - 9111"
"Caldwell Elementary - 0861"
"Carlton Palmore Elementary - 0061"
"Chain O' Lakes Elementary - 0933"
"Churchwell Elementary - 1841"
"Citrus Ridge Civics Academy - 1032"
"Cleveland Court Elementary - 0081"
"Combee Academy - 0091"
"Computer Networking - 9803"
"Crystal Lake Elementary - 0101"
"Crystal Lake Middle - 1501"
"Custodial Services - 9608"
"Daniel Jenkins Academy - 0311"
"Davenport Community Campus - 0916"
"Davenport SOTA - 0401"
"Denison Middle - 0491"
"Deputy Superintendent Office - 9101"
"Discipline - 9351"
"Dixieland Elementary - 0131"
"DJJ - 9352"
"DJJ B.E.S.T. - 9203"
"DJJ Bartow Youth Academy - 9203"
"DJJ Highlands Youth Academy - 9224"
"DJJ New Horizons - 9221"
"DJJ Pace Center - 9225"
"DJJ Polk Halfway House - 9207"
"DJJ Sheriff'S Office Detention - 9236"
"DJJ South County Ctr Bartow - 9228"
"Don Woods Opportunity Ctr - 0421"
"Doris Sanders Learning Ctr - 0092"
"Dr. N.E. Roberts Elementary - 1851"
"Drivers Ed & Athletics - 9325"
"Dundee Academy - 1781"
"Dundee Ridge Middle Academy - 1981"
"Eagle Lake Elementary - 1701"
"East Area Adult - 0871"
"Eastside Elementary - 0361"
"Elbert Elementary - 0591"
"Electronic Equipment Repair Services - 9802"
"Employee Health Clinic - 9412"
"Equity & Diversity Mgmt - 9113"
"ESE - 9365"
"ESOL - 9345"
"Facilities & Operations - 9601"
"Federal Programs - 9390"
"Finance - 9401"
"Floral Avenue Elementary - 0961"
"Frostproof Elementary - 1291"
"Frostproof Middle-Senior - 1801"
"Ft. Meade Middle-Senior - 0791"
"Garden Grove Elementary - 1711"
"Garner Elementary - 0601"
"Gause Academy - 1491"
"George Jenkins Senior - 1931"
"Gibbons Street Elementary - 0981"
"Government Affairs - 9112"
"Grants - 9349"
"Griffin Elementary - 1231"
"Haines City Senior - 1791"
"Harrison SOTA - 0033"
"Highland City Elementary - 1061"
"Highlands Grove Elementary - 1281"
"Horizons Elementary - 1362"
"Human Resource Services - 9301"
"Information Services - 9811"
"Information Technology - 9801"
"Instructional Television - 9822"
"Intec - 9821"
"Internal Audit Services - 9182"
"Inwood Elementary - 0611"
"Jean O'Dell Learning Ctr - 0962"
"Jesse Keen Elementary - 1241"
"Jewett Middle Academy - 0711"
"Jewett SOTA - 0712"
"K-12 Curriculum - 9335"
"Karen Siegel Academy - 0661"
"Kathleen Elementary - 1221"
"Kathleen Middle - 1191"
"Kathleen Senior - 1181"
"Kingsford Elementary - 1151"
"Lake Alfred Elementary - 0651"
"Lake Alfred-Addair Middle - 1662"
"Lake Gibson Middle - 1761"
"Lake Gibson Senior - 1762"
"Lake Marion Creek Middle - 1831"
"Lake Region Senior - 1991"
"Lake Shipp Elementary - 0621"
"Lakeland Highlands Middle - 1771"
"Lakeland Senior - 0031"
"Laurel Avenue Elementary - 1611"
"Lawton Chiles Middle Academy - 0043"
"Learning Support - 9364"
"Legal - 9181"
"Lena Vista Elementary - 0841"
"Lewis Elementary - 0771"
"Lewis-Anna Woodbury - 0802"
"Library Media Services - 9340"
"Lincoln Avenue Academy - 0251"
"Loughman Oaks Elementary - 1941"
"McLaughlin Middle - 1341"
"Medulla Elementary - 0181"
"Mulberry Middle - 1161"
"Mulberry Senior - 1131"
"Music Instruction - 9360"
"North Lakeland Elementary - 0201"
"Oscar J. Pope Elementary - 1521"
"Padgett Elementary - 1451"
"Palmetto Elementary - 1702"
"Payroll - 9403"
"Philip O'Brien Elementary - 0151"
"Physical Education - 9327"
"Pinewood Elementary - 1731"
"Polk City Elementary - 0881"
"Polk Education Foundation - 9114"
"Polk Pre-Collegiate Academy - 8002"
"Polk Virtual School - 7004"
"Preschool Programs - 9310"
"Print Shop - 9421"
"Professional Development - 9302"
"Public Relations - 9108"
"Purcell Elementary - 1141"
"Purchasing - 9420"
"R. Bruce Wagner Elementary - 0191"
"Regional Office 1 Elementary - 9391"
"Regional Office 2 Elementary - 9392"
"Regional Office 3 Middle - 9393"
"Regional Office 4 Senior - 9394"
"Ridge Community Senior - 0937"
"Ridge Teen Parent - 9205"
"Risk Management - 9410"
"Rochelle SOTA - 0261"
"Roosevelt Academy - 1381"
"Sandhill Elementary - 0341"
"School Board Services - 9180"
"School Improvement - 9395"
"School Nutrition - 9405"
"Scott Lake Elementary - 1681"
"Sikes Elementary - 1821"
"Sleepy Hill Elementary - 1271"
"Sleepy Hill Middle - 1971"
"Snively Elementary - 0631"
"Socrum Elementary - 1901"
"Southwest Elementary - 0231"
"Southwest Middle - 0051"
"Spessard Holland Elementary - 1908"
"Spook Hill Elementary - 1371"
"Stambaugh Middle - 0821"
"Stephens Elementary - 1751"
"Student Services - 9370"
"Summerlin Academy - 0905"
"Sup Services Courier - 9503"
"Sup Services Safe Schools - 9504"
"Sup Services-Recycling - 9502"
"Superintendent’s Office - 9100"
"Support Services Video Camera - 9501"
"Teaching & Learning - 9350"
"Tenoroc Senior - 1051"
"Traviss Career Tech - 1591"
"Union Academy - 0971"
"Valleyview Elementary - 1891"
"Wahneta Elementary - 0681"
"Wendell Watson Elementary - 0681"
"Wellness - 9373"
"Westwood Middle - 0571"
"Winston Academy - 1251"
"Winter Haven Senior - 0481"
)

	## Configure the DEPNotify Registration screen
	sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify PathToPlistFile /var/tmp/
	sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify RegisterMainTitle "Registration"
	sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify RegistrationButtonLabel Register
	sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify UITextFieldUpperLabel "Assign to User"
	sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify UITextFieldUpperPlaceholder "john.smith1"
	sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify UITextFieldLowerLabel "Computer SAP Number"
	sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify UITextFieldLowerPlaceholder "50012345"
	sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify UIPopUpMenuUpperLabel "Location"
	sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify UIPopUpMenuUpper -array  "${locationList[@]}" 
	sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify UIPopUpMenuLowerLabel "Computer Role"
	sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify UIPopUpMenuLower -array 'Staff' 'Student'

	## Launch DEPNotify
	open "/Applications/DEPNotify.app"

	## Wait for user to complete registration. This will create a registration plist with the user's information.
	## Loop here until that plist is created.
	while [ ! -f $registrationPlist ]; do
		sleep 1
	done

	## Once the plist is found, read the plist and place in variables.
	serialNumber=`defaults read $registrationPlist "Computer Serial"`
	user=`defaults read $registrationPlist "Assign to User"`
	computerRole=`defaults read $registrationPlist "Computer Role"`
	sapNumber=`defaults read $registrationPlist "Computer SAP Number"`
	location=`defaults read $registrationPlist "Location"`
	locationNumber=`echo $location | tail -c 5 | cut -c -4`
	locationName=`echo $location | sed 's/.\{7\}$//'`

	## Update DEPNotify's MainText area with the user's submitted information.
	echo "Command: MainTitle: Polk County Public Schools Mac Registration" >> $depLog
	echo "Command: MainText: We are setting up your Mac with a standard suite of software and security settings. \n \n Serial Number: $serialNumber \n Computer SAP Number: $sapNumber \n Assigned User: $user \n Location: $locationName \n Computer Role: $computerRole" >> $depLog
	echo "Status: Preparing computer for registration." >> $depLog

	sleep 1

	#########################
	## Begin Installations ##
	#########################

	## Prepare computer for registration
	echo "Status: Preparing computer for registration." >> $depLog
	/usr/sbin/systemsetup -settimezone "America/New_York"
	/usr/sbin/systemsetup -setusingnetworktime on
	/usr/sbin/systemsetup -setnetworktimeserver "time.apple.com"
	ntpdate -u time.apple.com

	## Check if already bound. If yes, unbind.
	echo "Status: Preparing computer for registration.." >> $depLog
	bindingCheck=`dsconfigad -show | grep "Active Directory Domain"`
	if [[ -z $bindingCheck ]]; then
		echo "Not bound. Skipping unbind..."
	else
		dsconfigad -force -remove -u bogusUsername -p bogusPassword
	fi

	## Rename computer to district standard
	echo "Status: Updating computer name to "${locationName} - ${sapNumber}"" >> $depLog
	/usr/sbin/scutil --set ComputerName "${locationName} - ${sapNumber}"
	/usr/sbin/scutil --set HostName "${locationName} - ${sapNumber}"

	environment=`echo $computerRole | cut -c1-1`
	computerID="L${locationNumber}${environment}-${sapNumber}"
	/usr/sbin/scutil --set LocalHostName $computerID
	
	## Get computer role for script logic
	if [[ "$computerRole" == "Student" ]]; then
		echo "Computer Role is: $computerRole"
		echo "Installing NoMAD Login"
		echo "Status: Installing required software..." >> $depLog
		$jamfBinary policy -event main-nomad-student
	else
		## Bind to Active Directory
		echo "Status: Binding computer to Active Directory..." >> $depLog
		ATTEMPTS=0
		SUCCESS=
		while [ -z "${SUCCESS}" ]; do
		  
		  if [ ${ATTEMPTS} -le 3 ]; then
		  	dsconfigad -add "polk-fl.net" -computer "${computerID}" -ou "${COMPUTERS_OU}" -username "${aduser}" -password "${adpass}" -force
		    sleep 2
		    IS_BOUND=`dsconfigad -show | grep "Active Directory Domain"`
		    
		    if [ -n "${IS_BOUND}" ]; then
		    	## Binding success!
		      	SUCCESS="YES"
		      	sleep 1
		    else
		    	## Bind failed. Retrying...
		      	sleep 3
		      	ATTEMPTS=`expr ${ATTEMPTS} + 1`
		    fi

		  else
		    ## Binding failed completely.
		    SUCCESS="NO"
			$jamfHelper -windowType hud -title Mac Registration -heading Error: 3 -alignHeading left -description "Could not bind computer to Active Directory after 3 tries. Make sure the computer is connected to the internet and re-run the Mac Registration policy in Self Service."  -alignDescription left -icon /Library/PCPS/resources/logo-pcps.png -button1 Quit -defaultButton 0 -lockHUD
			exit 0
		  fi
		
		done

		## Update Active Directory records
		dsconfigad -mobile enable
		dsconfigad -mobileconfirm disable
		dsconfigad -localhome enable
		dsconfigad -useuncpath disable
		dsconfigad -protocol smb
		dsconfigad -packetsign allow
		dsconfigad -packetencrypt allow
		dsconfigad -passinterval 0

		GROUP_MEMBERS=`dscl /Local/Default -read /Groups/com.apple.access_loginwindow GroupMembers 2>/dev/null`
		NESTED_GROUPS=`dscl /Local/Default -read /Groups/com.apple.access_loginwindow NestedGroups 2>/dev/null`

		if [ -z "${GROUP_MEMBERS}" ] && [ -z "${NESTED_GROUPS}" ]; then
			dseditgroup -o edit -n /Local/Default -a netaccounts -t group com.apple.access_loginwindow 2>/dev/null
		fi
	
	fi

	## Disable Time Machine's pop-up message whenever an external drive is plugged in
	echo "Status: Disabling Time Machine automatic backups..." >> $depLog
	/usr/bin/defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

	# Disable GateKeeper
	echo "Status: Disabling GateKeeper..." >> $depLog
	spctl --master-disable

	## Configure Apple Remote Desktop and activate service
	echo "Status: Configuring Remote Management settings..." >> $depLog
	ARD="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
	$ARD -configure -activate
	$ARD -configure -access -on
	$ARD -configure -allowAccessFor -specifiedUsers
	$ARD -configure -access -on -users jamfadmin -privs -all
	$ARD -configure -access -on -users administrator -privs -all

	## Add all current and future users to printer group
	echo "Status: Adding users to printer group..." >> $depLog
	/usr/sbin/dseditgroup -o edit -n /Local/Default -a everyone -t group lpadmin

	## Disable iCloud Setup screen
	echo "Status: Disabling iCloud Setup Assistant screens..." >> $depLog
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

	## Disable Diagnostic Reports screen
	echo "Status: Disabling Diagnostic Reports Setup Assistant screens..." >> $depLog
	# Define variables
	SUBMIT_TO_APPLE=NO
	SUBMIT_TO_APP_DEVELOPERS=NO

	# For future users
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

	## Enable system-wide scroll bars
	echo "Status: Enabling system-wide scroll bars..." >> $depLog
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

	## Update DEPNotify's screens
	echo "Command: MainTitle: Registration complete!" >> $depLog
	echo "Command: MainText: We're cleaning up some files that were used during setup." >> $depLog
	echo "Status: Restarting in a moment..." >> $depLog
	echo "Command: NotificationImage: /Library/PCPS/resources/logo-pcps.png"
	echo "Command: Notification: Registration complete!" >> $depLog

	## Remove LaunchDaemon
	rm /Library/LaunchDaemons/com.pcps.firstrun.plist
	
	## Submit updated info to Jamf
	$jamfBinary recon -endUsername $user -assetTag $sapNumber
	
	## Quit DEPNotify gracefully
	echo "Command: Quit" >> $depLog
	
	# Force computer restart
	sudo shutdown -r now
fi
exit 0