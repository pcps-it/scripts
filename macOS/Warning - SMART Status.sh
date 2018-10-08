#!/bin/bash
#
#	Script Name: Warning - SMART Status.sh
#	Version: 1.0
#	Last Update: 10/12/2016
#	Requirements:
#		- CocoaDialog
#
##################################################

## Assign CocoaDialog
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"

# Alert user
    msg=`$CD msgbox --no-newline \
    --icon "caution" \
    --title "Hard Drive Failure" \
    --informative-text "Your hard drive is reporting multiple failures and may cease to work in the near future. It is highly recommended you backup any important data and contact your Mac Administrator." \
    --button1 "OK"`

exit 0