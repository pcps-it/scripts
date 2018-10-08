#!/bin/sh

CD_APP="/Library/PCPS/apps/CocoaDialog.app/Contents/MacOS/CocoaDialog"
JAMF="/usr/local/bin/jamf"
ADUser="$4"
ADPass="$5"
ComputerOU="CN=Computers,DC=polk-fl,DC=net"

RefreshBox=`$CD_APP msgbox \
	--title "Mac Cleaner" \
	--text "WARNING!" \
	--icon "caution" \
	--informative-text "Clicking "Clean" will perform the following:

	-Deletes all user accounts
	-Deletes all files in the /Users/Shared folder
	-Maintenance tasks
	-Reboots computer" \
	--button1 "Clean" \
	--button2 "Cancel"`

	if [[ "$RefreshBox" == "1" ]]; then

		# Setup CocoaDialog's progressbar
		# create a named pipe
		rm -f /tmp/hpipe
		mkfifo /tmp/hpipe

		# create a background job which takes its input from the named pipe
		$CD_APP progressbar --title "Mac Cleaner" < /tmp/hpipe &

		# associate file descriptor 3 with that pipe and send a character through the pipe
		exec 3<> /tmp/hpipe
		echo -n . >&3

		
		#Check if bound to domain
		echo "10% Configuring system..." >&3
		echo "Configuring system..." 2>&1
		DomainCheck=`dsconfigad -show`

		if [[ "$DomainCheck" == "" ]]; then
			SerialNumber=`system_profiler SPHardwareDataType | grep "Serial Number" | awk '{print $4}'`
			dsconfigad -add "polk-fl.net" -computer "${SerialNumber}" -ou "${ComputerOU}" -username "${ADUser}" -password "${ADPass}" -force
			sleep 1
			dsconfigad -mobile enable
			dsconfigad -mobileconfirm disable
			dsconfigad -localhome enable
			dsconfigad -useuncpath disable
			dsconfigad -protocol smb
			dsconfigad -packetsign allow
			dsconfigad -packetencrypt allow
			dsconfigad -passinterval 0
			sleep 1


		fi

		#Check for Administrator account, if it doesn't have one, make one
		echo "25% Configuring system..." >&3
		echo "Configuring system..." 2>&1
		CheckAdmin=`dscl . -list /Users | grep "administrator"`

		if [[ "$CheckAdmin" == "" ]]; then
			$JAMF createAccount -username administrator -realname Administrator -password P@ssword -home /Users/administrator -admin -suppressSetupAssistant
		fi

		#Trash Shared User folder contents
		echo "48% Cleaning Shared Folder..." >&3
			echo "Cleaning Shared Folder..." 2>&1
		rm -rf /Users/Shared/*

		#Run Maintenance Tasks (Flush system caches, Flush User caches, run disk repair, Flush ByHost Files)
		echo "55% Repairing ByHost Files..." >&3
		echo "Fixing ByHost Files..." 2>&1
		$JAMF fixByHostFiles -target /

		echo "60% Repairing Disk Permissions..." >&3
		echo "Fixing Disk Permissions..." 2>&1
		$JAMF fixPermissions

		echo "65% Flushing Caches..." >&3
		echo "Flushing Caches..." 2>&1
		$JAMF flushCaches -flushSystem -flushUsers

		echo "70% Flushing Policy History..." >&3
		echo "Flushing Policy History..." 2>&1
		$JAMF flushPolicyHistory

		echo "75% Running Maintenance Tasks..." >&3
		echo "Running Maintenance Tasks..." 2>&1
		periodic daily weekly monthly
		
		
		#Delete all local/managed mobile accounts
		Users=`dscl . -list /Users | grep -v "_" | grep -v "administrator" | grep -v "jamfadmin" | grep -v "daemon" | grep -v "nobody" | grep -v "root" | grep -v "casperscreensharing" | grep -v "Guest"`
		Percent=76
		for item in $Users; do
			FolderSize=`du -sh /Users/$item | awk '{print $1}'`
			echo "${Percent}% Please wait. Deleting Account: $item ($FolderSize)" >&3
			echo "Please wait. Deleting Account: $item ($FolderSize)" 2>&1
			$JAMF deleteAccount -username $item -deleteHomeDirectory
			((Percent++))
			sleep 1

		done

		# Get currently logged in user
		loggedInUser=$(stat -f%Su /dev/console)
		rm -rf /Users/${loggedInUser}/Library/Keychains/*
	
		#Install First Run pkg
		echo "98% Creating FirstRun Files..." >&3
		echo "Creating FirstRun Files..." 2>&1
		rm -rf /Library/PCPS/resources/enrolled
cat > /Library/LaunchDaemons/com.pcps.firstrun.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.pcps.firstrun</string>
	<key>ProgramArguments</key>
	<array>
		<string>/usr/local/jamf/bin/jamf</string>
		<string>policy</string>
		<string>-event</string>
		<string>enroll</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StartInterval</key>
	<integer>15</integer>
</dict>
</plist>
EOF

		chown root:wheel /Library/LaunchDaemons/com.pcps.firstrun.plist
		chmod 644 /Library/LaunchDaemons/com.pcps.firstrun.plist


		#reboot
		echo "100% Rebooting..." >&3
		echo "Rebooting..." 2>&1
		sleep 3

		exec 3>&-
		rm -f /tmp/hpipe

		shutdown -r now


	fi

exit 0
