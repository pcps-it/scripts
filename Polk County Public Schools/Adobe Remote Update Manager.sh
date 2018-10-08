#!/bin/sh
rum="/usr/local/bin/RemoteUpdateManager"
installMode="$4"

if [ "$installMode" == "Cache" ]; then
	$rum --action=download
	touch /PCPS/resources/AdobeUpdateCache
fi

if [ "$installMode" == "Install" ]; then
	$rum --action=install
fi

exit 0