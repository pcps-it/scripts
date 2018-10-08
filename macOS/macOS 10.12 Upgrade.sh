#!/bin/bash

##Enter 0 for Full Screen, 1 for Utility window (screenshots available on GitHub)
userDialog=0

##Title to be used for userDialog (only applies to Utility Window)
title="macOS Sierra Upgrade"

##Heading to be used for userDialog
heading="Please wait as we prepare your computer for Sierra."

##Title to be used for userDialog
description="
This process will take approximately one hour. 
Your computer will reboot and begin the upgrade soon."

##Icon to be used for userDialog
##Default is macOS Sierra Installer logo which is included in the staged installer package
icon=/Users/Shared/Install\ macOS\ Sierra.app/Contents/Resources/InstallAssistant.icns

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# SYSTEM CHECKS
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

##Check if device is on battery or ac power
pwrAdapter=$( /usr/bin/pmset -g ps )
if [[ ${pwrAdapter} == *"AC Power"* ]]; then
    pwrStatus="OK"
    /bin/echo "Power Check: OK - AC Power Detected"
else
    pwrStatus="ERROR"
    /bin/echo "Power Check: ERROR - No AC Power Detected"
fi

##Check if free space > 15GB
#osMinor=$( /usr/bin/sw_vers -productVersion | awk -F. {'print $2'} )
#if [[ $osMinor -ge 12 ]]; then
#    freeSpace=$( /usr/sbin/diskutil info / | grep "Available Space" | awk '{print $4}' )
#else
#    freeSpace=$( /usr/sbin/diskutil info / | grep "Free Space" | awk '{print $4}' )
#fi
#
#if [[ ${freeSpace%.*} -ge 15 ]]; then
#    spaceStatus="OK"
#    /bin/echo "Disk Check: OK - ${freeSpace%.*}GB Free Space Detected"
#else
#    spaceStatus="ERROR"
#    /bin/echo "Disk Check: ERROR - ${freeSpace%.*}GB Free Space Detected"
#fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# CREATE FIRST BOOT SCRIPT
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

/bin/mkdir /usr/local/jamfps

/bin/echo "#!/bin/bash
## First Run Script to remove the installer.
## Clean up files
/bin/rm -fdr /Users/Shared/Install\ macOS\ Sierra.app
/bin/sleep 2
## Update Device Inventory
/usr/local/jamf/bin/jamf recon
## Remove LaunchDaemon
/bin/rm -f /Library/LaunchDaemons/com.jamfps.cleanupOSInstall.plist
## Remove Script
/bin/rm -fdr /usr/local/jamfps
exit 0" > /usr/local/jamfps/finishOSInstall.sh

/usr/sbin/chown root:admin /usr/local/jamfps/finishOSInstall.sh
/bin/chmod 755 /usr/local/jamfps/finishOSInstall.sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# LAUNCH DAEMON
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

cat << EOF > /Library/LaunchDaemons/com.jamfps.cleanupOSInstall.plist
<?xml version="1.0" encoding="UTF-8"?> 
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"> 
<plist version="1.0"> 
<dict>
    <key>Label</key> 
    <string>com.jamfps.cleanupOSInstall</string> 
    <key>ProgramArguments</key> 
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>/usr/local/jamfps/finishOSInstall.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict> 
</plist>
EOF

##Set the permission on the file just made.
/usr/sbin/chown root:wheel /Library/LaunchDaemons/com.jamfps.cleanupOSInstall.plist
/bin/chmod 644 /Library/LaunchDaemons/com.jamfps.cleanupOSInstall.plist

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# APPLICATION
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Create /Library/PCPS/resources directory if it does not exist
resourcesDIR="/Library/PCPS/resources"

if [ ! -d "${resourcesDIR}" ]; then
   mkdir -p $resourcesDIR
fi

installerIcon="installer-sierra.png"
iconFullPath="/Library/PCPS/resources/${installerIcon}"

curl -o ${resourcesDIR}/installer-sierra.png http://itvdb.polk-fl.net/downloads/jamf/images/installer-sierra.png
sleep 1

# Check if image downloaded correctly. If not, use the Self Service icon.
if [ ! -e "$iconFullPath" ]; then
   iconFullPath="/Applications/Self Service.app/Contents/resources/Self Service.icns"
fi

if [[ ${pwrStatus} == "OK" ]]; then
    ##Launch jamfHelper
    if [[ ${userDialog} == 0 ]]; then

        /bin/echo "Launching jamfHelper as FullScreen..."
        /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType fs -title "" -icon "$iconFullPath" -heading "$heading" -description "$description" &
        jamfHelperPID=$(echo $!)
    fi
    if [[ ${userDialog} == 1 ]]; then
        /bin/echo "Launching jamfHelper as Utility Window..."
        /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -title "$title" -icon "$iconFullPath" -heading "$heading" -description "$description" -iconSize 100 &
        jamfHelperPID=$(echo $!)
    fi

    # Download installer
    jamf policy -event main-sierra

    ##Begin Upgrade
    /bin/echo "Launching startosinstall..."
    /Users/Shared/Install\ macOS\ Sierra.app/Contents/Resources/startosinstall --applicationpath /Users/Shared/Install\ macOS\ Sierra.app --nointeraction --pidtosignal $jamfHelperPID &
    /bin/sleep 3
else
    /bin/echo "Launching jamfHelper Dialog (Requirements Not Met)..."
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -title "$title" -icon "$iconFullPath" -heading "Requirements Not Met" -description "We were unable to prepare your computer for macOS Sierra. Please ensure you are connected to power and that you have at least 15GB of Free Space. 
    
    If you continue to experience this issue, please contact the IT Support Center." -iconSize 100 -button1 "OK" -defaultButton 1
fi

exit 0