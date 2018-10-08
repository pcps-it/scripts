#!/bin/sh
jamfBinary="/usr/local/jamf/bin/jamf"
jssURL="$4"
apiuser="$5"
apipass="$6"

# Get Serial Number of computer
serialNumber=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Serial\ Number\ \(system\)/ {print $NF}'`

# Delete computer from on-prem JSS
curl -s -k -u $apiuser:$apipass -H "Content-Type: application/xml" "${jssURL}/JSSResource/computers/serialnumber/${serialNumber}" -X DELETE