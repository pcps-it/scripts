#!/bin/bash
CD_APP="/Library/PCPS/apps/CocoaDialog.app/Contents/MacOS/CocoaDialog"
jqBinary="/usr/local/bin/jq"
source "/Library/PCPS/apps/pashua.sh"
jssURL="$4"
apiURL="JSSResource/computers/serialnumber"
apiUser="$5"
apiPass="$6"
xmlHeader="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"

conf="
	# Window Title
	*.title = Mass Computer Updater
	*.floating = 1

	# Original Username
	ogUsername.type = textfield
	ogUsername.label = Original Username:
	ogUsername.width = 150

	# New Username
	newUsername.type = textfield
	newUsername.label = New Username:
	newUsername.width = 150

	# Cancel button
	cb.type = cancelbutton

	# Install button
	db.type = defaultbutton
	db.label = Continue
	"
pashua_run "$conf" "$customLocation"

if [[ "$db" == "1" ]]; then
	
	# Get all computers that are assigned to old user
	computerFetch=`curl -s -X GET --user "${apiUser}:${apiPass}" \
		${jssURL}/JSSResource/computers/match/${ogUsername} \
  		-H 'accept: application/json'`

  	serialNumbersArray=`echo "$computerFetch" | $jqBinary -r '.computers[].serial_number'`

  	newUserRealName=`dscl '/Active Directory/POLK-FL/All Domains' -read /Users/$newUsername RealName | grep -v ":"`
  	newUserEmail=`dscl '/Active Directory/POLK-FL/All Domains' -read /Users/$newUsername EMailAddress | awk '{print $2}'`

  	# Prompt user for confirmation window
  	conf="
	# Window Title
	*.title = Mass Computer Updater
	*.floating = 1

	# Text
	heading.type = text
	heading.default = ${ogUsername}'s computers will be replaced with:

	# New Information
	newUser.type = text
	newUser.default = Full Name: ${newUserRealName}[return]Username: $newUsername[return]Email Address: $newUserEmail

	# Cancel button
	cb.type = cancelbutton

	# Update button
	update.type = defaultbutton
	update.label = Update
	"
	pashua_run "$conf" "$customLocation"

	if [[ "$update" == "1" ]]; then
		echo " "
		echo "Starting Mass Update"
		echo " "

		apiData="
		<computer>
			<location>
				<username>$newUsername</username>
				<realname>$newUserRealName</realname>
				<real_name>$newUserRealName</real_name>
				<email_address>$newUserEmail</email_address>
			</location>
		</computer>"


		for i in $serialNumbersArray; do
			echo "Updating computer: $i"
			curl -sSu ${apiUser}:${apiPass} "${jssURL}/${apiURL}/$i" \
			-H "Content-Type: text/xml" \
			-d "${xmlHeader}${apiData}" \
			-X PUT  > /dev/null
		done


	else
		exit 0
	fi

else
	exit 0
fi

exit 0