#!/bin/sh
jamfURL="$4"
apiUser="$5"
apiPass="$6"

## Get computer's serial number
serialNumber=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformSerialNumber/{print $4}')
if [ $serialNumber = "" ]; then
	echo "*** Serial Number not found! Exiting..."
	exit 0
else
	echo "*** Serial Number: ${serialNumber}."
fi

## Add API to Jamf URL
apiURL="$jamfURL/JSSResource/computers/serialnumber/${serialNumber}/subset/extensionattributes"


## API Data
apiData="<computer><extension_attributes><extension_attribute><name>TV Productions</name><value>Yes</value></extension_attribute></extension_attributes></computer>"

## Write Extension Attribute
completeCurlCommand=`curl -s -f -k -u $apiUser:$apiPass -X PUT -H "Content-Type: text/xml" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$apiData" $apiURL`

exit 0