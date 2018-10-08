#!/bin/sh
apiURL="$4"
apiUser="$5"
apiPass="$6"
siteList="$7"

# Get full IP Address
IPAddress=`ifconfig | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}'`

shortIP=""
schoolIPAddress=""
if [ $IPAddress = "" ]; then
	echo "*** IP address could not be established. Exiting..."
	exit 0
else
	shortIP=`echo $IPAddress | cut -c1-2`
	if [ $shortIP = "10" ]; then
		schoolIPAddress=`echo $IPAddress | cut -c1-6`
		echo "*** School Location IP Address: ${schoolIPAddress}"
	else
		echo "*** Computer appears to be off campus with the IP address ${IPAddress}. Exiting..."
		#exit 0
	fi
fi

# Get computer's serial number
serialNumber=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformSerialNumber/{print $4}')
if [ $serialNumber = "" ]; then
	echo "*** Serial Number not found! Exiting..."
	exit 0
else
	echo "*** Serial Number: ${serialNumber}."
fi

siteNumber=`curl -s $siteList | grep "$schoolIPAddress" | awk -F":" '{print $2}'`
if [ $siteNumber = "" ]; then
	echo "*** Site could not be matched! Exiting..."
	exit 0
else
	echo "*** Matched site number: ${siteNumber}."
fi

# Get the Site Name of the site ID
siteName=`curl -H "Accept: text/xml" -sfku "${apiUser}:${apiPass}" $apiURL/JSSResource/sites/id/$siteNumber | awk -F'<name>|</name>' '{print $2}'`
echo "*** Site Name: ${siteName}."

# Update Site on Computer record
apiData="<computer><general><site><id>$siteNumber</id><name>$siteName</name></site></general></computer>"
curl -X PUT -H "Content-Type: application/xml" -s -k -u $apiUser:$apiPass -d "$apiData" "$apiURL/JSSResource/computers/serialnumber/$serialNumber/subset/general"
exit 0