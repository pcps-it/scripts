#!/bin/bash
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"

languageDropdown=`$CD standard-dropdown --title "Creative Cloud Language Selector" --icon "installer" --icon-size 48 --no-newline --text "Select the install language below:" --height "150" --float --string-output --items "English" "French" "German" "Portuguese" "Spanish" "Vietnamese"`

userSelection=`echo $languageDropdown | awk '{print $1}'`
selectedLanguage=`echo $languageDropdown | awk '{print $2}'`

if [ "$userSelection" == "Okay" ]; then
	if [ "$selectedLanguage" == "English" ]; then
		echo "User Selected: $selectedLanguage"
		defaults write .GlobalPreferences AppleLocale en_US
	fi

	if [ "$selectedLanguage" == "French" ]; then
		echo "User Selected: $selectedLanguage"
		defaults write .GlobalPreferences AppleLocale fr_FR
	fi

	if [ "$selectedLanguage" == "German" ]; then
		echo "User Selected: $selectedLanguage"
		defaults write .GlobalPreferences AppleLocale de_DE
	fi

	if [ "$selectedLanguage" == "Portuguese" ]; then
		echo "User Selected: $selectedLanguage"
		defaults write .GlobalPreferences AppleLocale pt_BR
	fi

	if [ "$selectedLanguage" == "Spanish" ]; then
		echo "User Selected: $selectedLanguage"
		defaults write .GlobalPreferences AppleLocale es_US
	fi

	if [ "$selectedLanguage" == "Vietnamese" ]; then
		echo "User Selected: $selectedLanguage"
		defaults write .GlobalPreferences AppleLocale vi_VN
	fi

	jamf policy -event main-premiereuninstall
	jamf policy -event main-premiere

fi

exit 0