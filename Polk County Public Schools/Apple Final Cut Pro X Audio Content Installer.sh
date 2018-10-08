#!/bin/sh
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
AudioDir="/Library/Audio/Apple Loops/Apple"
FCPSEDir="/Library/Audio/Apple Loops/Apple/Final Cut Pro Sound Effects"


if [[ ! -e $CD ]]; then
	echo "CocoaDialog not found. Installing..."
	jamf policy -event main-gui
fi

rv=`$CD yesno-msgbox --no-cancel --string-output --no-newline --icon "notice" --text "Additional Audio Content Available" --informative-text "Would you like to install audio content for Final Cut Pro X now?"`

echo "User selected: $rv"

if [ $rv == "Yes" ]; then
	jamf policy -event main-audiocontent

	ln -s "$AudioDir/01 Hip Hop" "$FCPSEDir"
	ln -s "$AudioDir/02 Electro House" "$FCPSEDir"
	ln -s "$AudioDir/03 Dubstep" "$FCPSEDir"
	ln -s "$AudioDir/04 Modern RnB" "$FCPSEDir"
	ln -s "$AudioDir/05 Tech House" "$FCPSEDir"
	ln -s "$AudioDir/06 Deep house" "$FCPSEDir"
	ln -s "$AudioDir/07 Chillwave" "$FCPSEDir"
	ln -s "$AudioDir/08 Indie Disco" "$FCPSEDir"
	ln -s "$AudioDir/09 Disco Funk" "$FCPSEDir"
	ln -s "$AudioDir/10 Vintage Breaks" "$FCPSEDir"
	ln -s "$AudioDir/11 Blues Garage" "$FCPSEDir"
	ln -s "$AudioDir/12 Chinese Traditional" "$FCPSEDir"
	ln -s "$AudioDir/13 Drummer" "$FCPSEDir"
	ln -s "$AudioDir/Apple Loops For GarageBand" "$FCPSEDir"
	ln -s "$AudioDir/Jam Pack 1" "$FCPSEDir"
	ln -s "$AudioDir/Jam Pack Remix Tools" "$FCPSEDir"
	ln -s "$AudioDir/Jam Pack Rhythm Section" "$FCPSEDir"
	ln -s "$AudioDir/Jam Pack Symphony Orchestra" "$FCPSEDir"
	ln -s "$AudioDir/Jam Pack World Music" "$FCPSEDir"
fi

exit 0