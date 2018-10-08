#!/bin/sh
# Quits background processes/daemons
osascript -e 'tell application "Microsoft Database Daemon" to quit'
osascript -e 'tell application "Microsoft AU Daemon" to quit'
osascript -e 'tell application "Office365Service" to quit'

# Kill Outlook to close any open drafted emails or it will fail
killall -kill "Microsoft Outlook"

# Close other Office Apps
osascript -e 'tell application "Remote Desktop Connection" to quit' 
osascript -e 'tell application "Microsoft Document Connection" to quit'
osascript -e 'tell application "Microsoft Messenger" to quit'
osascript -e 'tell application "Microsoft Communicator" to quit'
osascript -e 'tell application "Microsoft Excel" to quit'
osascript -e 'tell application "Microsoft PowerPoint" to quit'
osascript -e 'tell application "Microsoft Word" to quit'
osascript -e 'tell application "Microsoft Office Reminders" to quit'

# Pull current logged in user into 'user' variable.
user=`ls -l /dev/console | cut -d " " -f 4`

# Remove Apps, preferences, fonts, files, licensing, receipts, etc.
rm -R /Library/LaunchDaemons/com.microsoft.*
rm -R '/Library/Preferences/com.microsoft.office.licensing.plist'
rm -R /Library/PrivilegedHelperTools/com.microsoft.*
rm -R '/Applications/Microsoft Communicator.app/'
rm -R '/Applications/Microsoft Messenger.app/'
rm -R '/Applications/Microsoft Office 2011/'
rm -R '/Applications/Remote Desktop Connection.app/'
rm -Rf 'Applications/Microsoft Office 2011'
rm -R '/Library/Application Support/Microsoft/MAU2.0'
rm -R '/Library/Application Support/Microsoft/MERP2.0'
rm -R '/Library/Application Support/Microsoft/Office'
rm -R /Library/Automator/*Excel*
rm -R /Library/Automator/*Office*
rm -R /Library/Automator/*Outlook*
rm -R /Library/Automator/*PowerPoint*
rm -R /Library/Automator/*Word*
rm -R /Library/Automator/*Workbook*
rm -R '/Library/Automator/Get Parent Presentations of Slides.action'
rm -R '/Library/Automator/Set Document Settings.action'
rm -Rf /Library/Fonts/Microsoft/
rm -R /Library/Internet\ Plug-Ins/SharePoint*
rm -R /Library/Preferences/com.microsoft*
rm -R '/Library/Preferences/Microsoft/'

# Rename Microsoft User Data as Rename Microsoft User Data Archive
mv /Users/$user/Documents/Microsoft\ User\ Data /Users/$user/Documents/Microsoft\ User\ Data\ Archive

# Delete User Application Support
rm -Rf /Users/$user/Library/Application\ Support/Microsoft/Office

OFFICERECEIPTS=$(pkgutil --pkgs=com.microsoft.office.*)

for ARECEIPT in $OFFICERECEIPTS
do
			pkgutil --forget $ARECEIPT
	done

exit 0