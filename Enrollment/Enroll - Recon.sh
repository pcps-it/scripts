#!/bin/bash
baseURL="$4"
apiUser="$5"
apiPass="$6"
jamfBinary="/usr/local/jamf/bin/jamf"
depNotify="/Applications/Utilities/DEPNotify.app"
registrationPlist="/var/tmp/DEPNotify.plist"
prefPlist="Libray/Preferences/menu.nomad.DEPNotify.plist"

# Once the plist is found, read the plist and place in variables.
serialNumber=`defaults read $registrationPlist "Computer Serial"`
user=`defaults read $registrationPlist "Assign to User"`
computerRole=`defaults read $registrationPlist "Computer Role"`
sapNumber=`defaults read $registrationPlist "Computer SAP Number"`

# Update computer record in Jamf
JSSHostname="$baseURL/JSSResource/computers/serialnumber/$serialNumber/subset/extensionattributes"
XMLTOWRITE="<computer><extension_attributes><extension_attribute><name>Primary User</name><value>$computerRole</value></extension_attribute></extension_attributes></computer>"
curl -s -k -u $apiUser:$apiPass -X PUT -H "Content-Type: text/xml" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$XMLTOWRITE" $JSSHostname

# Submit updated info to Jamf
$jamfBinary recon -endUsername $user -assetTag $sapNumber
exit 0