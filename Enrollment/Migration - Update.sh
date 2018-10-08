#!/bin/sh
jamfBinary="/usr/local/jamf/bin/jamf"
jssURL="$4"
apiuser="$5"
apipass="$6"
dataFile="/tmp/jamfmigration"

if [ -e "$dataFile" ]; then
	assetTag=`awk '{print $1}' $dataFile`
	username=`awk '{print $2}' $dataFile`
	$jamfBinary recon -endUsername $username -assetTag $assetTag
fi

# Get Mac Address of computer
macAddress=`networksetup -getmacaddress en0 | awk '{print $3}' | sed 's/:/./g'`

# Delete computer from on-prem JSS
curl -s -k -u $apiuser:$apipass -H "Content-Type: application/xml" "${jssURL}/JSSResource/computers/macaddress/${macAddress}" -X DELETE