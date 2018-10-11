#!/bin/bash
#############################################################
# Script Description
#############################################################
#	Script Name: Enrollment - Configuration 3.0
#	Requirements:
#		- DEPNotify
#
#	Change Log:
#		9/21/18
#			- Initial creation
#		9/22/18
#			- Added numbered error handling messages to user
#		10/10/18
#			- Rearranged script to be more precise, easier to read, and to add future updates
#			- Added policy array idea from Jamf's DEPNotify script


#############################################################
# Master variable declarations
#############################################################
baseURL="$4"
apiUser="$5"
apiPass="$6"
jamfBinary="/usr/local/jamf/bin/jamf"
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
depNotify="/Applications/Utilities/DEPNotify.app"
depLog="/var/tmp/depnotify.log"
debugLog="/var/log/depNotifyDebug.log"
registrationPlist="/var/tmp/DEPNotify.plist"
bomFile="/var/tmp/com.depnotify.registration.done"
prefPlist="Libray/Preferences/menu.nomad.DEPNotify.plist"


#############################################################
# Program Options
#############################################################
# Array of policies that will run in order. format must be "Progress Bar Test, Policy Custome Trigger"
POLICY_ARRAY=(
	"Installing required software,main-pcps-gui"
	"Configuring system settings,enroll-systemsettings"
	"Configuring login system,main-nomad"
	"Updating computer record in Jamf,enroll-recon"
)

# Define School and Department location list
locationList=(
	"Acceleration & Innovation - 9107"
	"Alta Vista Elementary - 0331"
	"Alturas Elementary - 1041"
	"Apple Bistro - 9406"
	"Auburndale Central Elementary - 0851"
	"Auburndale Senior - 0811"
	"Bartow Academy - 0941"
	"Bartow Middle - 0931"
	"Bartow Senior - 0901"
	"Bartow IB - 0901"
	"Bartow Warehouse - 9422"
	"Ben Hill Griffin Elementary - 1921"
	"Bethune Academy - 0391"
	"Bill Duncan Opportunity Ctr - 2001"
	"Blake Academy - 1861"
	"Boone Middle - 0321"
	"Boswell Elementary - 1811"
	"Brigham Academy - 0531"
	"Business Process Support - 9111"
	"Caldwell Elementary - 0861"
	"Carlton Palmore Elementary - 0061"
	"Chain O' Lakes Elementary - 0933"
	"Churchwell Elementary - 1841"
	"Citrus Ridge Civics Academy - 1032"
	"Cleveland Court Elementary - 0081"
	"Combee Academy - 0091"
	"Computer Networking - 9803"
	"Crystal Lake Elementary - 0101"
	"Crystal Lake Middle - 1501"
	"Custodial Services - 9608"
	"Daniel Jenkins Academy - 0311"
	"Davenport Community Campus - 0916"
	"Davenport SOTA - 0401"
	"Denison Middle - 0491"
	"Deputy Superintendent Office - 9101"
	"Discipline - 9351"
	"Dixieland Elementary - 0131"
	"DJJ - 9352"
	"DJJ B.E.S.T. - 9203"
	"DJJ Bartow Youth Academy - 9203"
	"DJJ Highlands Youth Academy - 9224"
	"DJJ New Horizons - 9221"
	"DJJ Pace Center - 9225"
	"DJJ Polk Halfway House - 9207"
	"DJJ Sheriff'S Office Detention - 9236"
	"DJJ South County Ctr Bartow - 9228"
	"Don Woods Opportunity Ctr - 0421"
	"Doris Sanders Learning Ctr - 0092"
	"Dr. N.E. Roberts Elementary - 1851"
	"Drivers Ed & Athletics - 9325"
	"Dundee Academy - 1781"
	"Dundee Ridge Middle Academy - 1981"
	"Eagle Lake Elementary - 1701"
	"East Area Adult - 0871"
	"Eastside Elementary - 0361"
	"Elbert Elementary - 0591"
	"Electronic Equipment Repair Services - 9802"
	"Employee Health Clinic - 9412"
	"Equity & Diversity Mgmt - 9113"
	"ESE - 9365"
	"ESOL - 9345"
	"Facilities & Operations - 9601"
	"Federal Programs - 9390"
	"Finance - 9401"
	"Floral Avenue Elementary - 0961"
	"Frostproof Elementary - 1291"
	"Frostproof Middle-Senior - 1801"
	"Ft. Meade Middle-Senior - 0791"
	"Garden Grove Elementary - 1711"
	"Garner Elementary - 0601"
	"Gause Academy - 1491"
	"George Jenkins Senior - 1931"
	"Gibbons Street Elementary - 0981"
	"Government Affairs - 9112"
	"Grants - 9349"
	"Griffin Elementary - 1231"
	"Haines City Senior - 1791"
	"Harrison SOTA - 0033"
	"Highland City Elementary - 1061"
	"Highlands Grove Elementary - 1281"
	"Horizons Elementary - 1362"
	"Human Resource Services - 9301"
	"Information Services - 9811"
	"Information Technology - 9801"
	"Instructional Television - 9822"
	"Intec - 9821"
	"Internal Audit Services - 9182"
	"Inwood Elementary - 0611"
	"Jean O'Dell Learning Ctr - 0962"
	"Jesse Keen Elementary - 1241"
	"Jewett Middle Academy - 0711"
	"Jewett SOTA - 0712"
	"K-12 Curriculum - 9335"
	"Karen Siegel Academy - 0661"
	"Kathleen Elementary - 1221"
	"Kathleen Middle - 1191"
	"Kathleen Senior - 1181"
	"Kingsford Elementary - 1151"
	"Lake Alfred Elementary - 0651"
	"Lake Alfred-Addair Middle - 1662"
	"Lake Gibson Middle - 1761"
	"Lake Gibson Senior - 1762"
	"Lake Marion Creek Middle - 1831"
	"Lake Region Senior - 1991"
	"Lake Shipp Elementary - 0621"
	"Lakeland Highlands Middle - 1771"
	"Lakeland Senior - 0031"
	"Laurel Avenue Elementary - 1611"
	"Lawton Chiles Middle Academy - 0043"
	"Learning Support - 9364"
	"Legal - 9181"
	"Lena Vista Elementary - 0841"
	"Lewis Elementary - 0771"
	"Lewis-Anna Woodbury - 0802"
	"Library Media Services - 9340"
	"Lincoln Avenue Academy - 0251"
	"Loughman Oaks Elementary - 1941"
	"McLaughlin Middle - 1341"
	"Medulla Elementary - 0181"
	"Mulberry Middle - 1161"
	"Mulberry Senior - 1131"
	"Music Instruction - 9360"
	"North Lakeland Elementary - 0201"
	"Oscar J. Pope Elementary - 1521"
	"Padgett Elementary - 1451"
	"Palmetto Elementary - 1702"
	"Payroll - 9403"
	"Philip O'Brien Elementary - 0151"
	"Physical Education - 9327"
	"Pinewood Elementary - 1731"
	"Polk City Elementary - 0881"
	"Polk Education Foundation - 9114"
	"Polk Pre-Collegiate Academy - 8002"
	"Polk Virtual School - 7004"
	"Preschool Programs - 9310"
	"Print Shop - 9421"
	"Professional Development - 9302"
	"Public Relations - 9108"
	"Purcell Elementary - 1141"
	"Purchasing - 9420"
	"R. Bruce Wagner Elementary - 0191"
	"Regional Office 1 Elementary - 9391"
	"Regional Office 2 Elementary - 9392"
	"Regional Office 3 Middle - 9393"
	"Regional Office 4 Senior - 9394"
	"Ridge Community Senior - 0937"
	"Ridge Teen Parent - 9205"
	"Risk Management - 9410"
	"Rochelle SOTA - 0261"
	"Roosevelt Academy - 1381"
	"Sandhill Elementary - 0341"
	"School Board Services - 9180"
	"School Improvement - 9395"
	"School Nutrition - 9405"
	"Scott Lake Elementary - 1681"
	"Sikes Elementary - 1821"
	"Sleepy Hill Elementary - 1271"
	"Sleepy Hill Middle - 1971"
	"Snively Elementary - 0631"
	"Socrum Elementary - 1901"
	"Southwest Elementary - 0231"
	"Southwest Middle - 0051"
	"Spessard Holland Elementary - 1908"
	"Spook Hill Elementary - 1371"
	"Stambaugh Middle - 0821"
	"Stephens Elementary - 1751"
	"Student Services - 9370"
	"Summerlin Academy - 0905"
	"Sup Services Courier - 9503"
	"Sup Services Safe Schools - 9504"
	"Sup Services-Recycling - 9502"
	"Superintendent’s Office - 9100"
	"Support Services Video Camera - 9501"
	"Teaching & Learning - 9350"
	"Tenoroc Senior - 1051"
	"Traviss Career Tech - 1591"
	"Union Academy - 0971"
	"Valleyview Elementary - 1891"
	"Wahneta Elementary - 0681"
	"Wendell Watson Elementary - 0681"
	"Wellness - 9373"
	"Westwood Middle - 0571"
	"Winston Academy - 1251"
	"Winter Haven Senior - 0481"
)


#############################################################
# Core Logic
#############################################################
# Run DEP Notify will run after Apple Setup Assistant and must be run as the end user.
SETUP_ASSISTANT_PROCESS=$(pgrep -l "Setup Assistant")
until [ "$SETUP_ASSISTANT_PROCESS" = "" ]; do
	echo "$(date "+%a %h %d %H:%M:%S"): Setup Assistant Still Running. PID $SETUP_ASSISTANT_PROCESS." >> "$debugLog"
	sleep 1
	SETUP_ASSISTANT_PROCESS=$(pgrep -l "Setup Assistant")
done

# Checking to see if the Finder is running now before continuing
FINDER_PROCESS=$(pgrep -l "Finder")
until [ "$FINDER_PROCESS" != "" ]; do
	echo "$(date "+%a %h %d %H:%M:%S"): Finder process not found. Assuming device is at login screen." >> "$debugLog"
	sleep 1
	FINDER_PROCESS=$(pgrep -l "Finder")
done

# Get currently logged in user
loggedInUser=$(stat -f "%Su" "/dev/console")
echo "$(date "+%a %h %d %H:%M:%S"): Current user set to $loggedInUser." >> "$debugLog"

# Launch Self Service to download latest branding image
open -a "/Applications/Self Service.app" --hide

# Loop waiting on the branding image to properly show in the users library
CUSTOM_BRANDING_PNG="/Users/$loggedInUser/Library/Application Support/com.jamfsoftware.selfservice.mac/Documents/Images/brandingimage.png"
until [ -f "$CUSTOM_BRANDING_PNG" ]; do
	echo "$(date "+%a %h %d %H:%M:%S"): Waiting for branding image from Jamf Pro." >> "$debugLog"
	sleep 1
done

# Quit DEPNotify, in case it is running
echo "Command: Quit" >> $depLog

# Remove any DEPNotify related files so that new paramters can be set
rm -rf $depLog
rm -rf $registrationPlist
rm -rf $bomFile
rm "/Users/${loggedInUser}/${prefPlist}"

# Configure the main DEPNotify screen
echo "Command: WindowTitle: PCPS Mac Registration" >> $depLog
echo "Command: Image: $CUSTOM_BRANDING_PNG" >> $depLog
echo "Command: MainTitle: Click Register to begin." >> $depLog
echo "Command: MainText: " >> $depLog
echo "Status: " >> $depLog
echo "Command: ContinueButtonRegister: Register" >> $depLog

# Configure progress bar
ADDITIONAL_OPTIONS_COUNTER=1
ARRAY_LENGTH="$((${#POLICY_ARRAY[@]}+ADDITIONAL_OPTIONS_COUNTER))"
echo "Command: Determinate: $ARRAY_LENGTH" >> "$depLog"

## Configure the DEPNotify Registration screen
sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify PathToPlistFile /var/tmp/
sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify RegisterMainTitle "Registration"
sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify RegistrationButtonLabel Register
sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify UITextFieldUpperLabel "Assign to User"
sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify UITextFieldUpperPlaceholder "john.smith1"
sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify UITextFieldLowerLabel "Computer SAP Number"
sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify UITextFieldLowerPlaceholder "50012345"
sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify UIPopUpMenuUpperLabel "Location"
sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify UIPopUpMenuUpper -array  "${locationList[@]}" 
sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify UIPopUpMenuLowerLabel "Computer Role"
sudo -u "$loggedInUser" defaults write menu.nomad.DEPNotify UIPopUpMenuLower -array 'Staff' 'Student'

# Opening the app after initial configuration
sudo -u "$loggedInUser" "$depNotify"/Contents/MacOS/DEPNotify -path "$depLog" -fullScreen&

# Wait for user to complete registration. This will create a registration plist with the user's information.
# Loop here until that plist is created.
while [ ! -f $registrationPlist ]; do
	echo "$(date "+%a %h %d %H:%M:%S"): Waiting for registration plist." >> "$debugLog"
	sleep 1
done

# Once the plist is found, read the plist and place in variables.
serialNumber=`defaults read $registrationPlist "Computer Serial"`
user=`defaults read $registrationPlist "Assign to User"`
computerRole=`defaults read $registrationPlist "Computer Role"`
sapNumber=`defaults read $registrationPlist "Computer SAP Number"`
location=`defaults read $registrationPlist "Location"`
locationNumber=`echo $location | tail -c 5 | cut -c -4`
locationName=`echo $location | sed 's/.\{7\}$//'`

# Update DEPNotify's MainText area with the user's submitted information.
echo "Command: MainTitle: Polk County Public Schools Mac Registration" >> $depLog
echo "Command: MainText: We are setting up your Mac with a standard suite of software and security settings. \n \n Serial Number: $serialNumber \n Computer SAP Number: $sapNumber \n Assigned User: $user \n Location: $locationName \n Computer Role: $computerRole" >> $depLog
echo "Status: Preparing computer for registration." >> $depLog

sleep 3


#############################################################
# Installation Process
#############################################################
# Loop to run policies
for POLICY in "${POLICY_ARRAY[@]}"; do
	echo "Status: $(echo "$POLICY" | cut -d ',' -f1)" >> "$depLog"
	$jamfBinary policy -event "$(echo "$POLICY" | cut -d ',' -f2)"
done


#############################################################
# Cleanup Process
#############################################################
## Update DEPNotify's screens
echo "Command: MainTitle: Registration complete!" >> $depLog
echo "Command: MainText: We're cleaning up some files that were used during setup." >> $depLog



# Quit DEPNotify gracefully
echo "Command: Quit" >> $depLog

# Remove DEPNotify
rm -rf /Applications/Utilities/DEPNotify.app

# Force computer restart
sudo shutdown -r now
exit 0