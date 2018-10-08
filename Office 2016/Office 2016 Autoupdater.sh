#!/bin/bash

## Variables
jamfBinary="/usr/local/bin/jamf"
mauApp="/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app"

## Check if MAU is installed
if [[ ! -d $mauApp ]]; then
	echo "*** MAU does not exist. Downloading."
	$jamfBinary policy -event main-mau
fi

## Get version of MAU
mauVersion=`defaults read "$mauApp/Contents/info.plist" CFBundleShortVersionString`
echo "*** MAU Version: $mauVersion"

## Get major version
mauMajorVersion=`echo $mauVersion | cut -c1-1`
echo "*** MAU Major Version: $mauMajorVersion"

## Run MAU to automatically install any available updates
if [[ $mauMajorVersion -ge 4 ]]; then
	echo "*** Running MAU automatic updater..."
	"$mauApp/Contents/MacOS/msupdate" --install
else
	echo "*** MAU version does not support automatic updates. Installing 4.0..."
	$jamfBinary policy -event main-mau
	
	echo "*** Running MAU automatic updater..."
	"$mauApp/Contents/MacOS/msupdate" --install
fi
exit 0