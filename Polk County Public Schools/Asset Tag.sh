#!/bin/bash
#
#	Script Name: Asset Tag.sh
#	Version: 1.0
#	Last Update: 10/12/2016
#	Requirements:
#		- CocoaDialog
#
##################################################

## Get API username, password and license software ID values from script parameters
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
jssURL="$4"
apiuser="$5"
apipass="$6"


# Get computer's Mac Address so that the API can find the correct computer in the JSS database
macAddress=`networksetup -getmacaddress en0 | awk '{print $3}' | sed 's/:/./g'`

# Pull the current Asset Tag from JSS API
assetTag=$( curl -s -k -u $apiuser:$apipass -H "Content-Type: application/xml" "${jssURL}/JSSResource/computers/macaddress/${macAddress}" | awk -F'<asset_tag>|</asset_tag>' '{print $2}' )

if [ "$assetTag" = "" ]; then
    msg=`$CD standard-inputbox --no-newline \
    --value-required \
    --icon "help" \
    --title "SAP Number" \
    --informative-text "Enter the computer's eight-digit SAP number." \
    --button1 "OK"`

    assetTag=`echo $msg | awk '{print $2}'`
    sudo /usr/local/jamf/bin/jamf recon -assetTag $assetTag
fi

exit 0