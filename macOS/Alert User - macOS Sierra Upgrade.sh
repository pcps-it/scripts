#!/bin/bash
#
#	Script Name: Alert User: macOS Sierra Upgrade.sh
#
##################################################

## Assign CocoaDialog
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"


if [ ! -e $CD ]; then
	/usr/local/jamf/bin/jamf policy -event main-gui
fi

# Alert user
rv=`$CD yesno-msgbox --no-cancel --no-newline \
--title "Polk County Public Schools" \
--icon "notice" \
--text "macOS Upgrade Available" \
--informative-text "You must upgrade this computer to macOS Sierra 10.12 before August 14th.

This message will appear once a day until this computer has been upgraded.

Would you like to upgrade now?"`

if [ "$rv" == "1" ]; then
	/usr/local/jamf/bin/jamf policy -event sierraUpgrade
else
	exit 0
fi

exit 0