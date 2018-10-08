#!/bin/bash
apiUser="$4"
apiPass="$5"
baseURL="$6"
extAttrName="$7"
extAttrValue="$8"

serialNumber=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Serial\ Number\ \(system\)/ {print $NF}'`

JSSHostname="$baseURL/JSSResource/computers/serialnumber/$serialNumber/subset/extensionattributes"

XMLTOWRITE="<computer><extension_attributes><extension_attribute><name>$extAttrName</name><value>$extAttrValue</value></extension_attribute></extension_attributes></computer>"

curl -s -k -u $apiUser:$apiPass -X PUT -H "Content-Type: text/xml" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$XMLTOWRITE" $JSSHostname --verbose

exit 0