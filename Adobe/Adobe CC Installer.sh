#!/bin/bash

CD_APP="/Library/PCPS/apps/CocoaDialog.app/Contents/MacOS/CocoaDialog"
JAMF="/usr/local/bin/jamf"
Dockutil="/usr/local/bin/dockutil"
source "/Library/PCPS/apps/pashua.sh"
webicon="http://itvdb.polk-fl.net/downloads/jamf/images/adobecc.png"
icon="/Library/PCPS/resources/adobecc.png"

##################
# FUNCTION SETUP #
##################

function addDockIcon () {
	appPath=$1
	if [[ "$opDock" == "1" ]]; then
		echo "0 Adding Dock icon..." >&3
		sleep 1
		$Dockutil --add "$appPath" --allhomes
	fi
}

function uninstallApp () {
	appName=$1
	appDockName=$2
	appFolderName=$3
	if [[ "$opUninstall" == "1" ]]; then
		echo "0 Uninstalling: ${appName}..." >&3
		$Dockutil --remove "$appDockName"
		/tmp/$appFolderName/AdobeCCUninstaller
	fi				
}

function installApp () {
	appName=$1
	policyTrigger=$2
	echo "0 Installing: ${appName}..." >&3
	$JAMF policy -event $policyTrigger
}

function finishInstall {
	echo "0 Installing available Adobe updates..." >&3
	/usr/local/bin/RemoteUpdateManager

	echo "0 Submitting updated Inventory..." >&3
	$JAMF recon
}

function cc2015 {
	conf="
	# Window Title
	*.title = Adobe Creative Cloud 2015
	*.floating = 1

	# Image
	img.type = image
	img.maxwidth = 150
	img.relx = 65
	img.path = $icon

	# Select apps
	appList.type = text
	appList.rely = -15
	appList.default = Select the apps to install:

	# APP list
	appFlashPro.type = checkbox
	appFlashPro.relx = 20
	appFlashPro.rely = -15
	appFlashPro.label = Flash Professional
	appInDesign.type = checkbox
	appInDesign.relx = 20
	appInDesign.rely = -15
	appInDesign.label = In Design
	appPremiere.type = checkbox
	appPremiere.label = Premiere Pro
	appPremiere.relx = 20
	
	# Additional Options
	options.type = text
	options.default = Additional Options
	options.rely = -15
	opUninstall.type = checkbox
	opUninstall.relx = 20
	opUninstall.rely = -15
	opUninstall.default = 1
	opUninstall.label = Uninstall previous verions (if installed)
	opDock.type = checkbox
	opDock.relx = 20
	opDock.default = 1
	opDock.label = Add application icons to Dock for all users
	
	# Cancel button
	cb.type = cancelbutton

	# Install button
	db.type = defaultbutton
	db.label = Install
	"
	pashua_run "$conf" "$customLocation"
}

function cc2017 {
	conf="
	# Window Title
	*.title = Adobe Creative Cloud 2017
	*.floating = 1

	# Image
	img.type = image
	img.maxwidth = 150
	img.relx = 65
	img.path = $icon

	# Select apps
	appList.type = text
	appList.rely = -15
	appList.default = Select the apps to install:

	# APP list
	appAfterEffects.type = checkbox
	appAfterEffects.relx = 20
	appAfterEffects.rely = -15
	appAfterEffects.label = After Effects
	appPhotoshop.type = checkbox
	appPhotoshop.relx = 20
	appPhotoshop.rely = -15
	appPhotoshop.label = Photoshop
	premiereText.type = text
	premiereText.default = Premiere Pro:
	premiereText.rely = -15
	appPremiere.type = radiobutton
	appPremiere.relx = 20
	appPremiere.default = None
	appPremiere.option = None
	appPremiere.option = English
	appPremiere.option = French
	appPremiere.option = Spanish

	options.type = text
	options.default = Additional Options
	options.rely = -15
	opUninstall.type = checkbox
	opUninstall.relx = 20
	opUninstall.rely = -15
	opUninstall.default = 1
	opUninstall.label = Uninstall previous verions (if installed)
	opDock.type = checkbox
	opDock.relx = 20
	opDock.default = 1
	opDock.label = Add application icons to Dock for all users
	
	# Cancel button
	cb.type = cancelbutton

	# Install button
	db.type = defaultbutton
	db.label = Install
	"
	
	pashua_run "$conf" "$customLocation"
}

function cc2018 {
	conf="
	# Window Title
	*.title = Adobe Creative Cloud 2018
	*.floating = 1

	# Image
	img.type = image
	img.maxwidth = 150
	img.relx = 65
	img.path = $icon

	# Select apps
	appList.type = text
	appList.rely = -15
	appList.default = Select the apps to install:

	# APP list
	appAcrobatDC.type = checkbox
	appAcrobatDC.relx = 20
	appAcrobatDC.rely = -15
	appAcrobatDC.label = Acrobat DC
	appAfterEffects.type = checkbox
	appAfterEffects.relx = 20
	appAfterEffects.rely = -15
	appAfterEffects.label = After Effects
	appAnimate.type = checkbox
	appAnimate.relx = 20
	appAnimate.rely = -15
	appAnimate.label = Animate
	appAudition.type = checkbox
	appAudition.relx = 20
	appAudition.rely = -15
	appAudition.label = Audition
	appBridge.type = checkbox
	appBridge.relx = 20
	appBridge.rely = -15
	appBridge.label = Bridge
	appDreamweaver.type = checkbox
	appDreamweaver.relx = 20
	appDreamweaver.rely = -15
	appDreamweaver.label = Dreamweaver
	appIllustrator.type = checkbox
	appIllustrator.relx = 20
	appIllustrator.rely = -15
	appIllustrator.label = Illustrator
	appInDesign.type = checkbox
	appInDesign.relx = 20
	appInDesign.rely = -15
	appInDesign.label = In Design
	appInCopy.type = checkbox
	appInCopy.relx = 20
	appInCopy.rely = -15
	appInCopy.label = InCopy
	appLightroomClassic.type = checkbox
	appLightroomClassic.relx = 20
	appLightroomClassic.rely = -15
	appLightroomClassic.label = Lightroom Classic
	appPhotoshop.type = checkbox
	appPhotoshop.relx = 20
	appPhotoshop.rely = -15
	appPhotoshop.label = Photoshop
	appPrelude.type = checkbox
	appPrelude.relx = 20
	appPrelude.rely = -15
	appPrelude.label = Prelude
	premiereText.type = text
	premiereText.default = Premiere Pro:
	premiereText.rely = -15
	appPremiere.type = radiobutton
	appPremiere.relx = 20
	appPremiere.default = None
	appPremiere.option = None
	appPremiere.option = English
	appPremiere.option = French
	appPremiere.option = Spanish

	options.type = text
	options.default = Additional Options
	options.rely = -15
	opUninstall.type = checkbox
	opUninstall.relx = 20
	opUninstall.rely = -15
	opUninstall.default = 1
	opUninstall.label = Uninstall previous verions (if installed)
	opDock.type = checkbox
	opDock.relx = 20
	opDock.default = 1
	opDock.label = Add application icons to Dock for all users

	# Cancel button
	cb.type = cancelbutton

	# Install button
	db.type = defaultbutton
	db.label = Install
	"

	pashua_run "$conf" "$customLocation"
}


##################
# BEGIN SCRIPT #
##################

YearSelectionBox=`$CD_APP dropdown \
	--title "Adobe Creative Cloud" \
	--text "Select a version to install:" \
	--icon "installer" \
	--items "Adobe CC 2018" "Adobe CC 2017" "Adobe CC 2015" \
	--button1 "Next" \
	--button2 "Cancel"`

UserSelection=`echo $YearSelectionBox | awk '{print $1}'`
Year=`echo $YearSelectionBox | awk '{print $2}'`



if [[ "$UserSelection" == "1" ]]; then

	curl -o $icon $webicon
	sleep 1
	if [[ ! -e "$icon" ]]; then
		icon="/Applications/Self Service.app/Contents/Resources/Self Service.icns"
	fi

	if [[ "$Year" == "0" ]]; then
		cc2018

		if [ "$db" == "1" ]; then
			# create a named pipe
			rm -f /tmp/hpipe
			mkfifo /tmp/hpipe

			# create a background job which takes its input from the named pipe
			$CD_APP progressbar --indeterminate --float --title "Adobe Creative Cloud 2018 Installer" --text "Please wait while we configure your system for installation..." < /tmp/hpipe &

			# associate file descriptor 3 with that pipe and send a character through the pipe
			exec 3<> /tmp/hpipe
			echo -n . >&3

			if [[ "$opUninstall" == "1" ]]; then
				$JAMF policy -event "main-adobe-cc-uninstall"
			fi

			if [[ "$appAcrobatDC" == "1" ]]; then
				installApp "Acrobat DC" "main-adobe-acrobatdc-2018"
				
				addDockIcon "/Applications/Adobe Acrobat DC/Adobe Acrobat.app"

			fi

			if [[ "$appAfterEffects" == "1" ]]; then
				
				uninstallApp "After Effects" "Adobe After Effects CC 2018" "Adobe_AfterEffects_Uninstall"

				installApp "After Effects" "main-adobe-aftereffects-2018"
				
				addDockIcon "/Applications/Adobe After Effects CC 2018/Adobe After Effects CC 2018.app"
			
			fi

			if [[ "$appAnimate" == "1" ]]; then
				
				uninstallApp "Animate" "Adobe Animate CC 2018" "Adobe_Animate_Uninstall"
				
				installApp "Animate" "main-adobe-animate-2018"
			
				addDockIcon "/Applications/Adobe Animate CC 2018/Adobe Animate CC 2018.app"
			
			fi

			if [[ "$appAudition" == "1" ]]; then
				
				uninstallApp "Audition" "Adobe Audition CC 2018" "Adobe_Audition_Uninstall"

				installApp "Audition" "main-adobe-audition-2018"
				
				addDockIcon "/Applications/Adobe Audition CC 2018/Adobe Audition CC 2018.app"
			
			fi

			if [[ "$appBridge" == "1" ]]; then			
				
				uninstallApp "Bridge" "Adobe Bridge CC 2018" "Adobe_Bridge_Uninstall"
				
				installApp "Bridge" "main-adobe-bridge-2018"
			
				addDockIcon "/Applications/Adobe Bridge CC 2018/Adobe Bridge CC 2018.app"
			
			fi

			if [[ "$appDreamweaver" == "1" ]]; then
				
				uninstallApp "Dreamweaver" "Adobe Dreamweaver CC 2018" "Adobe_Dreamweaver_Uninstall"

				installApp "Dreamweaver" "main-adobe-dreamweaver-2018"
				
				addDockIcon "/Applications/Adobe Dreamweaver CC 2018/Adobe Dreamweaver CC 2018.app"
			
			fi

			if [[ "$appIllustrator" == "1" ]]; then
				
				uninstallApp "Illustrator" "Adobe Illustrator CC 2018" "Adobe_Illustrator_Uninstall"

				installApp "Illustrator" "main-adobe-illustrator-2018"
				
				addDockIcon "/Applications/Adobe Illustrator CC 2018/Adobe Illustrator.app"
			
			fi

			if [[ "$appInDesign" == "1" ]]; then
				
				uninstallApp "InDesign" "Adobe InDesign CC 2018" "Adobe_InDesign_Uninstall"

				installApp "InDesign" "main-adobe-indesign-2018"
				
				addDockIcon "/Applications/Adobe InDesign CC 2018/Adobe InDesign CC 2018.app"
			
			fi

			if [[ "$appInCopy" == "1" ]]; then
				
				uninstallApp "InCopy" "Adobe InCopy CC 2018" "Adobe_InCopy_Uninstall"

				installApp "InCopy" "main-adobe-incopy-2018"
				
				addDockIcon "/Applications/Adobe InCopy CC 2018/Adobe InCopy CC 2018.app"
			
			fi

			if [[ "$appLightroomClassic" == "1" ]]; then
				
				installApp "Lightroom Classic CC" "main-adobe-lightroomclassic"
				
				addDockIcon "/Applications/Adobe Lightroom Classic CC/Adobe Lightroom Classic CC.app"
			
			fi

			if [[ "$appPhotoshop" == "1" ]]; then
				
				uninstallApp "Photoshop" "Adobe Photoshop CC 2018" "Adobe_Photoshop_Uninstall"

				installApp "Photoshop" "main-adobe-photoshop-2018"
				
				addDockIcon "/Applications/Adobe Photoshop CC 2018/Adobe Photoshop CC 2018.app"
			
			fi

			if [[ "$appPrelude" == "1" ]]; then
				
				uninstallApp "Prelude" "Adobe Prelude CC 2018" "Adobe_Prelude_Uninstall"

				installApp "Prelude" "main-adobe-prelude-2018"
				
				addDockIcon "/Applications/Adobe Prelude CC 2018/Adobe Prelude CC 2018.app"
			
			fi
			
			if [[ "$appPremiere" == "None" ]]; then
				echo "None"
			
			elif [[ "$appPremiere" == "English" ]]; then
				
				uninstallApp "Premiere Pro" "Adobe Premiere Pro CC 2018" "Adobe_PremierePro_Uninstall"

				installApp "Premiere Pro (English)" "main-adobe-premiere-2018-english"
				
				addDockIcon "/Applications/Adobe Premiere Pro CC 2018/Adobe Premiere Pro CC 2018.app"

			elif [[ "$appPremiere" == "French" ]]; then
				
				uninstallApp "Premiere Pro" "Adobe Premiere Pro CC 2018" "Adobe_PremierePro_Uninstall"

				installApp "Premiere Pro (French)" "main-adobe-premiere-2018-french"
				
				addDockIcon "/Applications/Adobe Premiere Pro CC 2018/Adobe Premiere Pro CC 2018.app"

			elif [[ "$appPremiere" == "Spanish" ]]; then
				
				uninstallApp "Premiere Pro" "Adobe Premiere Pro CC 2018" "Adobe_PremierePro_Uninstall"

				installApp "Premiere Pro (Spanish)" "main-adobe-premiere-2018-spanish"
				
				addDockIcon "/Applications/Adobe Premiere Pro CC 2018/Adobe Premiere Pro CC 2018.app"
			
			fi

			finishInstall

			# now turn off the progress bar by closing file descriptor 3
			exec 3>&-

			# wait for all background jobs to exit
			wait
			rm -f /tmp/hpipe
			
		fi

	elif [[ "$Year" == "1" ]]; then
		cc2017

		if [ "$db" == "1" ]; then
			# create a named pipe
			rm -f /tmp/hpipe
			mkfifo /tmp/hpipe

			# create a background job which takes its input from the named pipe
			$CD_APP progressbar --indeterminate --float --title "Adobe Creative Cloud 2017 Installer" --text "Please wait while we configure your system for installation..." < /tmp/hpipe &

			# associate file descriptor 3 with that pipe and send a character through the pipe
			exec 3<> /tmp/hpipe
			echo -n . >&3

			if [[ "$opUninstall" == "1" ]]; then
				$JAMF policy -event "main-adobe-cc-uninstall"
			fi

			if [[ "$appAfterEffects" == "1" ]]; then
				
				uninstallApp "After Effects" "Adobe After Effects CC 2017" "Adobe_AfterEffects_Uninstall"

				installApp "After Effects" "main-adobe-aftereffects-2017"
				
				addDockIcon "/Applications/Adobe After Effects CC 2017/Adobe After Effects CC 2017.app"
			
			fi

			if [[ "$appPhotoshop" == "1" ]]; then
				
				uninstallApp "Photoshop" "Adobe Photoshop CC 2017" "Adobe_Photoshop_Uninstall"

				installApp "Photoshop" "main-adobe-photoshop-2017"
				
				addDockIcon "/Applications/Adobe Photoshop CC 2017/Adobe Photoshop CC 2017.app"
			
			fi

			if [[ "$appPremiere" == "None" ]]; then
				echo "None"
			
			elif [[ "$appPremiere" == "English" ]]; then
				
				uninstallApp "Premiere Pro" "Adobe Premiere Pro CC 2017" "Adobe_PremierePro_Uninstall"

				installApp "Premiere Pro" "main-adobe-premiere-2017-english"
				
				addDockIcon "/Applications/Adobe Premiere Pro CC 2017/Adobe Premiere Pro CC 2017.app"

			elif [[ "$appPremiere" == "French" ]]; then
				
				uninstallApp "Premiere Pro" "Adobe Premiere Pro CC 2017" "Adobe_PremierePro_Uninstall"

				installApp "Premiere Pro (French)" "main-adobe-premiere-2017-french"
				
				addDockIcon "/Applications/Adobe Premiere Pro CC 2017/Adobe Premiere Pro CC 2017.app"
			
			elif [[ "$appPremiere" == "Spanish" ]]; then
				
				uninstallApp "Premiere Pro" "Adobe Premiere Pro CC 2017" "Adobe_PremierePro_Uninstall"

				installApp "Premiere Pro (Spanish)" "main-adobe-premiere-2017-spanish"
				
				addDockIcon "/Applications/Adobe Premiere Pro CC 2017/Adobe Premiere Pro CC 2017.app"
			
			fi

			finishInstall

			# now turn off the progress bar by closing file descriptor 3
			exec 3>&-

			# wait for all background jobs to exit
			wait
			rm -f /tmp/hpipe

		fi

	elif [[ "$Year" == "2" ]]; then
		cc2015

		if [ "$db" == "1" ]; then
			
			# create a named pipe
			rm -f /tmp/hpipe
			mkfifo /tmp/hpipe

			# create a background job which takes its input from the named pipe
			$CD_APP progressbar --indeterminate --float --title "Adobe Creative Cloud 2015 Installer" --text "Please wait while we configure your system for installation..." < /tmp/hpipe &

			# associate file descriptor 3 with that pipe and send a character through the pipe
			exec 3<> /tmp/hpipe
			echo -n . >&3

			if [[ "$opUninstall" == "1" ]]; then
				$JAMF policy -event "main-adobe-cc-uninstall"
			fi

			if [[ "$appFlashPro" == "1" ]]; then
				installApp "Flash Professional" "main-adobe-flashpro-2015"
				
				addDockIcon "/Applications/Adobe Flash CC 2015/Adobe Flash CC 2015.app"
			
			fi
			
			if [[ "$appInDesign" == "1" ]]; then
				installApp "In Design" "main-adobe-indesign-2015"
				
				addDockIcon "/Applications/Adobe In Design CC 2015/Adobe In Design CC 2015.app"
			
			fi

			if [[ "$appPremiere" == "1" ]]; then
				
				uninstallApp "Premiere Pro" "Adobe Premiere Pro CC 2015" "Adobe_PremierePro_Uninstall"

				installApp "Premiere Pro" "main-adobe-premiere-2015"
				
				addDockIcon "/Applications/Adobe Premiere Pro CC 2015/Adobe Premiere Pro CC 2015.app"
			
			fi

			finishInstall

			# now turn off the progress bar by closing file descriptor 3
			exec 3>&-

			# wait for all background jobs to exit
			wait
			rm -f /tmp/hpipe
			
		fi

	fi
	
fi

exit 0