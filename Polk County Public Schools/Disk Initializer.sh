#!/bin/bash
jamfBinary="/usr/local/jamf/bin/jamf"
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"

# Get list of mounted external drives
diskList=$(diskutil list external | grep "2:" | awk '{print $NF}')

# Initialize arrays and set counting variables to zero
declare -a diskArray
declare -a nameArray
diskIndex=0
nameIndex=0

# Loop through each disk and assign it to the diskArray array.
# While looping, grab the Volume Name of each disk and assign it to nameArray array.
for item in $diskList; do
	diskArray[$diskIndex]="$item"
	
	volumeName=`diskutil info "$item" | grep "Volume Name:" | awk -F" {2,}" '{print $3}'`
	nameArray[$nameIndex]="$volumeName"

	echo "*** Disk Details ***
	Disk: $item
	Name: \"$volumeName\"
	Array Position: diskArray[$diskIndex]
	"

	((diskIndex++))
	((nameIndex++))
done

# Display error if no disks are located and exit script gracefully
if [ "${diskArray[0]}" == "" ]; then
	noDiskError=`$CD msgbox --float \
	--title "Disk Initializer" \
	--icon "stop" \
	--text "Error 1: No external disks located!" \
	--informative-text "Connect an external disk or flash drive and try again." \
	--button1 "Quit"`
	exit 0
fi

# Present Disk Selection dialog to user
DiskSelectionBox=`$CD dropdown --float \
	--title "Disk Initializer" \
	--icon "usb" \
	--text "Select a disk to initialize:" \
	--items "${nameArray[@]}" \
	--button1 "Continue" \
	--button2 "Cancel"`

# Exit script gracefully if user chose to cancel
if [ "$DiskSelectionBox" == "0" ]; then
	exit 0
fi

# Get user choices
userSelection=`echo $DiskSelectionBox | awk '{print $1}'`

if [ "$userSelection" == "1" ]; then
	# Since the dropdown box is in the same order as the arrays,
	# we can use the chosen number to reference the array index
	chosenDisk=`echo $DiskSelectionBox | awk '{print $2}'`

	# Display Volune Name change dialog box
	DiskNameBox=`$CD inputbox --float \
		--title "Disk Initializer" \
		--icon "usb" \
		--informative-text "What do you want to name the drive?"\
		--text "Untitled" \
		--button1 "Format" \
		--button2 "Cancel"`

	# Get user choices
	userSelection=`echo $DiskNameBox | awk '{print $1}'`
	newVolumeName=`echo ${DiskNameBox:1}`

	# Exit script if user chooses to cancel
	if [ "$DiskNameBox" == "2" ]; then
		exit 0
	fi

	# Confirmation Dialog
	DiskConfirmBox=`$CD yesno-msgbox --float \
		--title "Disk Initializer" \
		--icon "caution" \
		--no-cancel \
		--text "The following action cannot be undone!" \
		--informative-text "You are about to erase all data on \"${nameArray[$chosenDisk]}\" and rename it to \"$newVolumeName\".

Do you wish to proceed?"`
	
	if [ "$DiskConfirmBox" == "1" ]; then
		# create a named pipe
		rm -f /tmp/hpipe
		mkfifo /tmp/hpipe

		# create a background job which takes its input from the named pipe
		$CD progressbar --indeterminate --float --title "Disk Initializer" --text "Erasing \"${nameArray[$chosenDisk]}\"..." < /tmp/hpipe &

		# associate file descriptor 3 with that pipe and send a character through the pipe
		exec 3<> /tmp/hpipe
		echo -n . >&3

		diskutil eraseDisk jhfs+ "$newVolumeName" "${diskArray[$chosenDisk]:0:5}"

		# now turn off the progress bar by closing file descriptor 3
		exec 3>&-

		# wait for all background jobs to exit
		wait
		rm -f /tmp/hpipe
	else
		exit 0
	fi
else
	exit 0
fi

exit 0