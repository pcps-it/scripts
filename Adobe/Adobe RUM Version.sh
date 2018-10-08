#!/bin/bash
rum=/usr/local/bin/RemoteUpdateManager

result=`$rum | grep "version" | awk '{print $5}'`

if [ "$result" == "" ]; then
	echo "<result>Not Installed</result>"
else
	echo "<result>$result</result>"
fi