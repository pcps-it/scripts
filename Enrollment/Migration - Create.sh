#!/bin/sh
jamfBinary="/usr/local/jamf/bin/jamf"
jssURL="$4"
apiuser="$5"
apipass="$6"

# Get serial number
serialNumber=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Serial\ Number\ \(system\)/ {print $NF}'`
echo "Serial Number: $serialNumber"

# Computer lookup in API
filteredComputer=$(curl -H "Accept: application/xml" -sfku "${apiuser}:${apipass}" "${jssURL}/JSSResource/computers/serialnumber/$serialNumber")

# Filter Asset Tag and Username
assetTag=$(echo $filteredComputer | /usr/bin/awk -F'<asset_tag>|</asset_tag>' '{print $2}')
assignedUser=$(echo $filteredComputer | /usr/bin/awk -F'<username>|</username>' '{print $2}')

# Create /tmp/jamfmigration file with details
echo "Writing $assetTag and $assignedUser to /tmp/jamfmigration..."
echo "$assetTag $assignedUser" > /tmp/jamfmigration