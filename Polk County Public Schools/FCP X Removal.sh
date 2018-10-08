#!/bin/bash
jamfBinary="/usr/local/jamf/bin/jamf"
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"

rm -rf "/Applications/Final Cut Pro.app"

$jamfBinary recon

$CD bubble --icon "notice"  --timeout "15" \
--title "Final Cut Pro X Removed" --text "Final Cut Pro X has been removed because it has not been opened in over 90 days.

You may reinstall the software from Self Service."

exit 0