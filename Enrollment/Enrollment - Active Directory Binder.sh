#!/bin/sh
#
#	Script Name: Enrollment - Active Directory Binder.sh
#	Version: 1.7.3
#	Last Update: 5/22/2017
#	Requirements:
#		- CocoaDialog
#		- Pashua
#
#	Change Log:
#		6/27/17
#			Added Accelerated & Learning department
#		5/22/17
#			Added Networking department
#		3/15/17
#			Corrected typo in McLaughlin Middle name
#		2/10/17
#			Rearranged workflow to get GUI in front of user more quickly
#		1/20/17
#			Added logic to determine the last UserID on system before creating Administrator account.
#		12/5/2016
#			Better use front-end
#		11/7/2016
#			Updated typo "Chain of Lake Elementary" to "Chain of Lakes Elementary"
#
##################################################
jamfBinary="/usr/local/jamf/bin/jamf"
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
jssURL="$4"
apiuser="$5"
apipass="$6"
aduser="$7"
adpass="$8"
MYDIR="/Library/PCPS/apps/"

# Include pashua.sh to be able to use the 2 functions defined in that file
source "$MYDIR/pashua.sh"

SAP=""
SAPNUMBER=""
locationNumber=""
USER=""
environmentLetter=""
AD_DOMAIN="polk-fl.net"
COMPUTERS_OU="CN=Computers,DC=polk-fl,DC=net"

is_ip_address() {
  IP_REGEX="\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
  IP_CHECK=`echo ${1} | egrep ${IP_REGEX}`
  if [ ${#IP_CHECK} -gt 0 ]
  then
    return 0
  else
    return 1
  fi
}

resourcesDIR="/Library/PCPS/resources"
if [ ! -d "${resourcesDIR}" ]; then
	mkdir -p $resourcesDIR
fi


# Checking for required hard-wired Ethernet
ethernetStatus=`ifconfig en0 | awk '/status: / {print $2}'`

# Get serial number
serialNumber=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Serial\ Number\ \(system\)/ {print $NF}'`

# Determine computer model to select correct image
computerModel=`system_profiler SPHardwareDataType | grep "Model Name:" | awk '{print $3}'`
computerIcon=""

if [ "${computerModel}" == "iMac" ]; then
		curl -o ${resourcesDIR}/model-iMac.png http://itvdb.polk-fl.net/downloads/MacEnroller/images/model-iMac.png
		computerIcon="model-iMac.png"
	elif [ "${computerModel}" == "MacBook" ]; then
		curl -o ${resourcesDIR}/model-MacBook.png http://itvdb.polk-fl.net/downloads/MacEnroller/images/model-MacBook.png
		computerIcon="model-MacBook.png"
	elif [ "${computerModel}" == "Mac" ]; then
		curl -o ${resourcesDIR}/model-MacMini.png http://itvdb.polk-fl.net/downloads/MacEnroller/images/model-MacMini.png
		computerIcon="model-MacMini.png"
	elif [ "${computerModel}" == "MacPro" ]; then
		curl -o ${resourcesDIR}/model-MacPro.png http://itvdb.polk-fl.net/downloads/MacEnroller/images/model-MacPro.png
		computerIcon="model-MacPro.png"
	else
		curl -o ${resourcesDIR}/model-all.png http://itvdb.polk-fl.net/downloads/MacEnroller/images/model-all.png
		computerIcon="model-all.png"
fi

db=""
while [ "$db" == "" ]; do	
	conf="
	# Window Title
	*.title = Mac Registration
	*.floating = 1
	*.y = 25

	# Computer image
	img.type = image
	img.maxwidth = 200
	img.relx = 47
	img.path = ${resourcesDIR}/${computerIcon}

	# Serial Number
	serial.type = text
	serial.relx = 45
	serial.default = Computer Serial: ${serialNumber}

	# Combobox: School
	school.type = combobox
	school.label = School or Department:
	school.width = 250
	school.completion = 2
	school.default =  
	school.option = Acceleration & Innovation
	school.option = Alta Vista Elementary
	school.option = Alturas Elementary
	school.option = Auburndale Central Elementary
	school.option = Auburndale Senior
	school.option = Bartow Academy
	school.option = Bartow Municipal Airport
	school.option = Bartow Middle
	school.option = Bartow Senior
	school.option = Bartow Senior - IB
	school.option = Ben Hill Griffin Elementary
	school.option = Bethune Academy
	school.option = Bill Duncan Opportunity Center
	school.option = Blake Academy
	school.option = Boone Middle
	school.option = Boswell Elementary
	school.option = Brigham Academy
	school.option = Caldwell Elementary
	school.option = Carlton Palmore Elementary
	school.option = Chain of Lakes Elementary
	school.option = Churchwell Elementary
	school.option = Citrus Ridge Civics Academy
	school.option = Cleveland Court Elementary
	school.option = Combee Elementary
	school.option = Crystal Lake Elementary
	school.option = Crystal Lake Middle
	school.option = Daniel Jenkins Academy
	school.option = Davenport School of the Arts
	school.option = Denison Middle
	school.option = Dixieland Elementary
	school.option = Don E. Woods Opportunity Center
	school.option = Doris A. Sanders Learning Center
	school.option = Dr. N. E. Roberts Elementary
	school.option = Dundee Academy
	school.option = Dundee Ridge Middle
	school.option = Eagle Lake Elementary
	school.option = East Area Adult
	school.option = Eastside Elementary
	school.option = Elbert Elementary
	school.option = Electronic Equipment Repair Services
	school.option = English for Speakers of Other Languages
	school.option = Floral Avenue Elementary
	school.option = Fort Meade Middle-Senior
	school.option = Frostproof Elementary
	school.option = Frostproof Middle-Senior
	school.option = Garden Grove Elementary
	school.option = Garner Elementary
	school.option = Gause Academy
	school.option = George Jenkins Senior
	school.option = Gibbons Street Elementary
	school.option = Griffin Elementary
	school.option = Haines City Senior
	school.option = Haines City Senior - IB
	school.option = Harrison School for the Arts
	school.option = Highland City Elementary
	school.option = Highlands Grove Elementary
	school.option = Horizons Elementary
	school.option = Information Systems & Technology
	school.option = Instructional Television
	school.option = Inwood Elementary
	school.option = Jean O'Dell Elementary
	school.option = Jesse Keen Elementary
	school.option = Jewett Middle Academy
	school.option = Jewett School of the Arts
	school.option = Karen M. Siegal Academy
	school.option = Kathleen Elementary
	school.option = Kathleen Middle
	school.option = Kathleen Senior
	school.option = Kingsford Elementary
	school.option = Lake Alfred Elementary
	school.option = Lake Alfred-Addair Middle
	school.option = Lake Gibson Middle
	school.option = Lake Gibson Senior
	school.option = Lake Marion Creek Middle
	school.option = Lake Region Senior
	school.option = Lake Shipp Elementary
	school.option = Lake Wales Senior
	school.option = Lakeland Highlands Middle
	school.option = Lakeland Senior
	school.option = Laurel Elementary
	school.option = Lawton Chiles Middle Academy
	school.option = Lena Vista Elementary
	school.option = Lewis Elementary - Anna Woodbury Campus
	school.option = Lewis Elementary - Lewis Campus
	school.option = Library Media Services
	school.option = Lincoln Avenue Academy
	school.option = Loughman Oaks Elementary
	school.option = McLaughlin Middle
	school.option = Medulla Elementary
	school.option = Mulberry Middle
	school.option = Mulberry Senior
	school.option = Networking
	school.option = North Lakeland Elementary
	school.option = Oscar J. Pope Elementary
	school.option = Padgett Elementary
	school.option = Palmetto Elementary
	school.option = Philip O'Brien Elementary
	school.option = Pinewood Elementary
	school.option = Polk Avenue Elementary
	school.option = Polk City Elementary
	school.option = Polk Life and Learning Center
	school.option = Professional Development
	school.option = Public Relations
	school.option = Purcell Elementary
	school.option = R. Bruce Wagner Elementary
	school.option = Ridge Community Senior
	school.option = Rochelle School of the Arts
	school.option = Roosevelt Academy
	school.option = Sandhill Elementary
	school.option = School Technology Services
	school.option = Scott Lake Elementary
	school.option = Sikes Elementary
	school.option = Sleepy Hill Elementary
	school.option = Sleepy Hill Middle
	school.option = Snively Elementary
	school.option = Socrum Elementary
	school.option = Southwest Elementary
	school.option = Southwest Middle
	school.option = Spessard L. Holland Elementary
	school.option = Spook Hill Elementary
	school.option = Stambaugh Middle
	school.option = Stephens Elementary
	school.option = Tenoroc Senior
	school.option = Traviss Career Center
	school.option = Union Academy
	school.option = Valleyview Elementary
	school.option = Wahneta Elementary
	school.option = Wendell Watson Elementary
	school.option = Westwood Middle
	school.option = Winston Academy
	school.option = Winter Haven Senior
	school.mandatory = TRUE
	school.placeholder = Start typing a school name...

	# Textfield: username
	clientUser.type = textfield
	clientUser.label = Assign computer to a user in the form of "john.smith":
	clientUser.placeholder = First.LastName
	clientUser.mandatory = TRUE

	# Textfield: sap
	sap.type = textfield
	sap.label = Computer's eight-digit SAP:
	sap.placeholder = 50123456
	sap.mandatory = TRUE

	# Radio: Computer's User Environment
	environment.type = radiobutton
	environment.label = Select the computer's primary use:
	environment.option = Administrator
	environment.option = Lab
	environment.option = Student
	environment.option = Teacher
	environment.mandatory = TRUE

	# Cancel button
	cb.type = cancelbutton
	cb.disabled = 1

	# Register button
	db.type = defaultbutton
	db.label = Register
	db.tooltip = Register this computer.
	"
		
	if [ -d '/Volumes/Pashua/Pashua.app' ]; then
		# Looks like the Pashua disk image is mounted. Run from there.
		customLocation='/Volumes/Pashua'
	else
		# Search for Pashua in the standard locations
		customLocation=''
	fi

	pashua_run "$conf" "$customLocation"

	# Install CocoaDialog for user feedback
	$jamfBinary policy -event main-cocoadialog

	if [ "$db" == "" ]; then
		$CD msgbox --title "Mac Enrollment" --icon "caution" --text "Registration cannot be skipped." --button1 "OK"
	fi

done




# REDFINE VARIABLES AS LETTERS INSTEAD OF FULL WORDS AS DEFINED BY PCSB'S NAMING STANDARDS
if [ "$environment" == "Administrator" ]; then
	environmentLetter="A"
elif [ "$environment" == "Lab" ]; then
	environmentLetter="L"
elif [ "$environment" == "Student" ]; then
	environmentLetter="S"
elif [ "$environment" == "Teacher" ]; then
	environmentLetter="T"
fi


# Setup CocoaDialog's progressbar
# create a named pipe
rm -f /tmp/hpipe
mkfifo /tmp/hpipe

# create a background job which takes its input from the named pipe
$CD progressbar --title "Active Directory Binder" < /tmp/hpipe &

# associate file descriptor 3 with that pipe and send a character through the pipe
exec 3<> /tmp/hpipe
echo -n . >&3

echo "Checking network configuration..."
echo "0% Checking network configuration..." >&3
ATTEMPTS=0
MAX_ATTEMPTS=10
while ! (netstat -rn -f inet | grep -q default)
do
  if [ ${ATTEMPTS} -le ${MAX_ATTEMPTS} ]
  then
    echo "Waiting for the default route to be active..."
    sleep 5
    ATTEMPTS=`expr ${ATTEMPTS} + 1`
  else
    echo "Network not configured, AD binding failed after (${MAX_ATTEMPTS} attempts)." 2>&1
	
	NETWORKERROR=`$CD msgbox --title "Active Directory Binder" --text "Binding failed after ${MAX_ATTEMPTS} attempts." \
	--informative-text "Make sure you are connected to the internet via a hard-wired ethernet cable and try again." \
	--button1 "Exit" --icon stop --no-newline --float`

    exit 1
  fi
done

echo "2% Success." >&3

# Wait for the related server to be reachable
# NB: AD service entries must be correctly set in DNS
SUCCESS=
is_ip_address "${AD_DOMAIN}"
if [ ${?} -eq 0 ]
then
  # the AD_DOMAIN variable contains an IP address, let's try to ping the server
  echo "Testing ${AD_DOMAIN} reachability" 2>&1  
  if ping -t 5 -c 1 "${AD_DOMAIN}" | grep "round-trip"
  then
    echo "Ping successful!" 2>&1
    SUCCESS="YES"
  else
    echo "Ping failed..." 2>&1
  fi
else
  ATTEMPTS=0
  MAX_ATTEMPTS=3
  while [ -z "${SUCCESS}" ]
  do
    if [ ${ATTEMPTS} -lt ${MAX_ATTEMPTS} ]
    then
      AD_DOMAIN_IPS=( `host "${AD_DOMAIN}" | grep " has address " | cut -f 4 -d " "` )
      for AD_DOMAIN_IP in ${AD_DOMAIN_IPS[@]}
      do
        echo "Testing ${AD_DOMAIN} reachability on address ${AD_DOMAIN_IP}" 2>&1 
        echo "3% Testing ${AD_DOMAIN} reachability... (${ATTEMPTS} attempts)" >&3
        if ping -t 5 -c 1 ${AD_DOMAIN_IP} | grep "round-trip"
        then
          echo "Ping successful!" 2>&1
          echo "10% Success." >&3
          SUCCESS="YES"
        else
          echo "Ping failed..." 2>&1
        fi
        if [ "${SUCCESS}" = "YES" ]
        then
          break
        fi
      done
      if [ -z "${SUCCESS}" ]
      then
        echo "An error occurred while trying to get ${AD_DOMAIN} IP addresses, new attempt in 3 seconds..." 2>&1
        echo "3% Error getting ${AD_DOMAIN} IP address. Retrying in 3 seconds..." >&3
        sleep 3
        ATTEMPTS=`expr ${ATTEMPTS} + 1`
      fi
    else
      echo "Cannot get any IP address for ${AD_DOMAIN} (${MAX_ATTEMPTS} attempts), aborting lookup..." 2>&1
      break
    fi
  done
fi

if [ -z "${SUCCESS}" ]
then
  echo "Cannot reach any IP address of the domain ${AD_DOMAIN}." 2>&1
  echo "AD binding failed." 2>&1
  NETWORKERROR=`$CD msgbox --title "Active Directory Binder" --text "Binding failed after ${MAX_ATTEMPTS} attempts." \
	--informative-text "Make sure you are connected to the internet via a hard-wired ethernet cable and try again." \
	--button1 "Exit" --icon stop --no-newline --float`
  exit 1
fi

echo "10% Success." >&3
sleep 1

echo "15% Setting Time Zone..." >&3
# Set time zone in preparation for AD binding
/usr/sbin/systemsetup -settimezone "America/New_York"
/usr/sbin/systemsetup -setusingnetworktime on
/usr/sbin/systemsetup -setnetworktimeserver "time.apple.com"
sleep 1

echo "20% Gathering school's location number..." >&3
echo "Gathering school's location number..." 2>&1

# Get computer's Mac Address so that the API can find the correct computer in the JSS database
macAddress=`networksetup -getmacaddress en0 | awk '{print $3}' | sed 's/:/./g'`

# Pull all of the computer's data from JSS
computerFetch=$(curl -sfku ${apiuser}:${apipass} ${jssURL}/JSSResource/computers/macaddress/${macAddress})

# Get the first two segments from both the Ethernet and Wi-Fi adapters.
#ipEthernet=`ifconfig en0 | grep inet | grep -v inet6 | awk '{print $2}' | cut -c 1-6`
#ipWifi=`ifconfig en1 | grep inet | grep -v inet6 | awk '{print $2}' | cut -c 1-6`

if [ "${school}" == "Acceleration & Innovation" ]; then
	school="Acceleration & Innovation"
	locationNumber=9107
elif [ "${school}" == "Alta Vista Elementary" ]; then
	school="Alta Vista Elementary"
	locationNumber=0331
elif  [ "${school}" == "Alturas Elementary" ]; then
	school="Alturas Elementary"
	locationNumber=1041
elif  [ "${school}" == "Auburndale Central Elementary" ]; then
	school="Auburndale Central Elementary"
	locationNumber=0851
elif  [ "${school}" == "Auburndale Senior" ]; then
	school="Auburndale Senior"
	locationNumber=0811
elif  [ "${school}" == "Bartow Academy" ]; then
	school="Bartow Academy"
	locationNumber=0941
elif  [ "${school}" == "Bartow Middle" ]; then
	school="Bartow Middle"
	locationNumber=0931
elif  [ "${school}" == "Bartow Minicipal Airport" ]; then
	school="Bartow Municipal Airport"
	locationNumber=9365
elif  [ "${school}" == "Bartow Senior" ]; then
	school="Bartow Senior"
	locationNumber=0901
elif  [ "${school}" == "Bartow Senior - IB" ]; then
	school="Bartow Senior IB"
	locationNumber=0903
elif  [ "${school}" == "Ben Hill Griffin Jr. Elementary" ]; then
	school="Ben Hill Griffin Jr Elementary"
	locationNumber=1921
elif  [ "${school}" == "Bethune Academy" ]; then
	school="Bethune Academy"
	locationNumber=0391
elif  [ "${school}" == "Bill Duncan Opportunity Center" ]; then
	school="Bill Duncan Opportunity Center"
	locationNumber=2001
elif  [ "${school}" == "Blake Academy" ]; then
	school="Blake Academy"
	locationNumber=1861
elif  [ "${school}" == "Boone Middle" ]; then
	school="Boone Middle"
	locationNumber=0321
elif  [ "${school}" == "Boswell Elementary" ]; then
	school="Boswell Elementary"
	locationNumber=1811
elif  [ "${school}" == "Brigham Academy" ]; then
	school="Brigham Academy"
	locationNumber=0531
elif  [ "${school}" == "Caldwell Elementary" ]; then
	school="Caldwell Elementary"
	locationNumber=0861
elif  [ "${school}" == "Carlton Palmore Elementary" ]; then
	school="Carlton Palmore Elementary"
	locationNumber=0061
elif  [ "${school}" == "Chain of Lakes Elementary" ]; then
	school="Chain of Lakes Elementary"
	locationNumber=0933
elif  [ "${school}" == "Churchwell Elementary" ]; then
	school="Churchwell Elementary"
	locationNumber=1841
elif  [ "${school}" == "Citrus Ridge Civics Academy" ]; then
    school="Citrus Ridge Civics Academy"
	locationNumber=1032
elif  [ "${school}" == "Cleveland Court Elementary" ]; then
	school="Cleveland Court Elementary"
	locationNumber=0081
elif  [ "${school}" == "Combee Elementary" ]; then
	school="Combee Elementary"
	locationNumber=0091
elif  [ "${school}" == "Crystal Lake Elementary" ]; then
	school="Crystal Lake Elementary"
	locationNumber=0101
elif  [ "${school}" == "Crystal Lake Middle" ]; then
	school="Crystal Lake Middle"
	locationNumber=1501
elif  [ "${school}" == "Daniel Jenkins Academy" ]; then
	school="Daniel Jenkins Academy"
	locationNumber=0311
elif  [ "${school}" == "Davenport School of the Arts" ]; then
	school="Davenport School of the Arts"
	locationNumber=0401
elif  [ "${school}" == "Denison Middle" ]; then
	school="Denison Middle"
	locationNumber=0491
elif  [ "${school}" == "Dixieland Elementary" ]; then
	school="Dixieland Elementary"
	locationNumber=0131
elif  [ "${school}" == "Don Woods Opportunity Center" ]; then
	school="Don Woods Opportunity Center"
	locationNumber=0421
elif  [ "${school}" == "Doris A. Sanders Learning Center" ]; then
	school="Doris A Sanders Learning Center"
	locationNumber=0092
elif  [ "${school}" == "Dr. N. E. Roberts Elementary" ]; then
	school="Dr. N.E. Roberts Elementary"
	locationNumber=1821
elif  [ "${school}" == "Dundee Academy" ]; then
	school="Dundee Academy"
	locationNumber=1781
elif  [ "${school}" == "Dundee Ridge Middle" ]; then
	school="Dundee Ridge Middle"
	locationNumber=1981
elif  [ "${school}" == "Eagle Lake Elementary" ]; then
	school="Eagle Lake Elementary"
	locationNumber=1701
elif  [ "${school}" == "East Area Adult School" ]; then
	school="East Area Adult School"
	locationNumber=0871
elif  [ "${school}" == "Eastside Elementary" ]; then
	school="Eastside Elementary"
	locationNumber=0361
elif  [ "${school}" == "Elbert Elementary" ]; then
	school="Elbert Elementary"
	locationNumber=0591
elif  [ "${school}" == "Electronic Equipment Repair Services" ]; then
	school="EERS"
	locationNumber=9802
elif  [ "${school}" == "English Speakers of Other Languages" ]; then
	school="ESOL"
	locationNumber=9345
elif  [ "${school}" == "Floral Avenue Elementary" ]; then
	school="Floral Avenue Elementary"
	locationNumber=0961
elif  [ "${school}" == "Fort Meade Middle-Senior" ]; then
	school="Fort Meade Middle-Senior"
	locationNumber=0791
elif  [ "${school}" == "Frostproof Elementary" ]; then
	school="Frostproof Elementary"
	locationNumber=1291
elif  [ "${school}" == "Frostproof Middle-Senior" ]; then
	school="Frostproof Middle-Senior"
	locationNumber=1801
elif  [ "${school}" == "Garden Grove Elementary" ]; then
	school="Garden Grove Elementary"
	locationNumber=1711
elif  [ "${school}" == "Garner Elementary" ]; then
	school="Garner Elementary"
	locationNumber=0601
elif  [ "${school}" == "Gause Academy" ]; then
	school="Gause Academy"
	locationNumber=1491
elif  [ "${school}" == "George Jenkins Senior" ]; then
	school="George Jenkins Senior"
	locationNumber=1931
elif  [ "${school}" == "Gibbons Street Elementary" ]; then
	school="Gibbons Street Elementary"
	locationNumber=0981
elif  [ "${school}" == "Griffin Elementary" ]; then
	school="Griffin Elementary"
	locationNumber=1231
elif  [ "${school}" == "Haines City Senior" ]; then
	school="Haines City Senior"
	locationNumber=1791
elif  [ "${school}" == "Haines City Senior - IB" ]; then
	school="Haines City Senior IB"
	locationNumber=1741
elif  [ "${school}" == "Harrison School for the Arts" ]; then
	school="Harrison School for the Arts"
	locationNumber=0033
elif  [ "${school}" == "Highland City Elementary" ]; then
	school="Highland City Elementary"
	locationNumber=1061
elif  [ "${school}" == "Highlands Grove Elementary" ]; then
	school="Highlands Grove Elementary"
	locationNumber=1281
elif  [ "${school}" == "Horizons Elementary" ]; then
	school="Horizons Elementary"
	locationNumber=1362
elif  [ "${school}" == "Information Systems & Technology" ]; then
	school="IST"
	locationNumber=9801
elif  [ "${school}" == "Inwood Elementary" ]; then
	school="Inwood Elementary"
	locationNumber=0611
elif  [ "${school}" == "Instructional Television" ]; then
	school="Instructional Television"
	locationNumber=9822
elif  [ "${school}" == "Jean O'Dell Learning Center" ]; then
	school="Jean O'Dell Learning Center"
	locationNumber=0000
elif  [ "${school}" == "Jesse Keen Elementary" ]; then
	school="Jesse Keen Elementary"
	locationNumber=1241
elif  [ "${school}" == "Jewett Middle Academy" ]; then
	school="Jewett Middle Academy"
	locationNumber=0711
elif  [ "${school}" == "Jewett School of the Arts" ]; then
	school="Jewett School of the Arts"
	locationNumber=0712
elif  [ "${school}" == "Jim Miles Professional Development Center" ]; then
	school="Jim Miles Professional Development Center"
	locationNumber=9821
elif  [ "${school}" == "Karen M. Siegal Academy" ]; then
	school="Karen M. Siegal Academy"
	locationNumber=0661
elif  [ "${school}" == "Kathleen Elementary" ]; then
	school="Kathleen Elementary"
	locationNumber=1221
elif  [ "${school}" == "Kathleen Middle" ]; then
	school="Kathleen Middle"
	locationNumber=1191
elif  [ "${school}" == "Kathleen Senior" ]; then
	school="Kathleen Senior"
	locationNumber=1181
elif  [ "${school}" == "Kingsford Elementary" ]; then
	school="Kingsford Elementary"
	locationNumber=
elif  [ "${school}" == "Lake Alfred Elementary" ]; then
	school="Lake Alfred Elementary"
	locationNumber=0651
elif  [ "${school}" == "Lake Alfred-Addair Middle" ]; then
	school="Lake Alfred-Addair Middle"
	locationNumber=1662
elif  [ "${school}" == "Lake Gibson Middle" ]; then
	school="Lake Gibson Middle"
	locationNumber=1761
elif  [ "${school}" == "Lake Gibson Senior" ]; then
	school="Lake Gibson Senior"
	locationNumber=1762
elif  [ "${school}" == "Lake Marion Creek Middle" ]; then
	school="Lake Marion Creek Middle"
	locationNumber=1831
elif  [ "${school}" == "Lake Region Senior" ]; then
	school="Lake Region Senior"
	locationNumber=1991
elif  [ "${school}" == "Lake Shipp Elementary" ]; then
	school="Lake Shipp Elementary"
	locationNumber=0621
elif  [ "${school}" == "Lake Wales Senior" ]; then
	school="Lake Wales Senior"
	locationNumber=1721
elif  [ "${school}" == "Lakeland Highlands Middle" ]; then
	school="Lakeland Highlands Middle"
	locationNumber=1771
elif  [ "${school}" == "Lakeland Senior" ]; then
	school="Lakeland Senior"
	locationNumber=0031
elif  [ "${school}" == "Laurel Elementary" ]; then
	school="Laurel Elementary"
	locationNumber=1611
elif  [ "${school}" == "Lawton Chiles Middle Academy" ]; then
	school="Lawton Chiles Middle Academy"
	locationNumber=0043
elif  [ "${school}" == "Lena Vista Elementary" ]; then
	school="Lena Vista Elementary"
	locationNumber=0841
elif  [ "${school}" == "Lewis Elementary - Anna Woodbury Campus" ]; then
	school="Lewis Elementary - Anna Woodbury Campus"
	locationNumber=0802
elif  [ "${school}" == "Lewis Elementary - Lewis Campus" ]; then
	school="Lewis Elementary - Lewis Campus"
	locationNumber=0771
elif  [ "${school}" == "Library Media Services" ]; then
	school="Library Media Services"
	locationNumber=9340
elif  [ "${school}" == "Lincoln Avenue Academy" ]; then
	school="Lincoln Avenue Academy"
	locationNumber=0251
elif  [ "${school}" == "Loughman Oaks Elementary" ]; then
	school="Loughman Oaks Elementary"
	locationNumber=1941
elif  [ "${school}" == "McLaughlin Academy" ]; then
	school="McLaughlin Academy"
	locationNumber=1341
elif  [ "${school}" == "Medulla Elementary" ]; then
	school="Medulla Elementary"
	locationNumber=0181
elif  [ "${school}" == "Mulberry Middle" ]; then
	school="Mulberry Middle"
	locationNumber=1161
elif  [ "${school}" == "Mulberry Senior" ]; then
	school="Mulberry Senior"
	locationNumber=1131
elif  [ "${school}" == "Networking" ]; then
	school="Networking"
	locationNumber=9803
elif  [ "${school}" == "North Lakeland Elementary" ]; then
	school="North Lakeland Elementary"
	locationNumber=0201
elif  [ "${school}" == "Oscar J. Pope Elementary" ]; then
	school="Oscar J Pope Elementary"
	locationNumber=1521
elif  [ "${school}" == "Padgett Elementary" ]; then
	school="Padgett Elementary"
	locationNumber=1451
elif  [ "${school}" == "Palmetto Elementary" ]; then
	school="Palmetto Elementary"
	locationNumber=1702
elif  [ "${school}" == "Philip O'Brien Elementary" ]; then
	school="Philip O'Brien Elementary"
	locationNumber=0151
elif  [ "${school}" == "Pinewood Elementary" ]; then
	school="Pinewood Elementary"
	locationNumber=1731
elif  [ "${school}" == "Polk Avenue Elementary" ]; then
	school="Polk Avenue Elementary"
	locationNumber=1351
elif  [ "${school}" == "Polk City Elementary" ]; then
	school="Polk City Elementary"
	locationNumber=0881
elif  [ "${school}" == "Polk Life and Learning Center" ]; then
	school="Polk Life and Learning Center"
	locationNumber=0962
elif  [ "${school}" == "Professional Development" ]; then
	school="Professional Development"
	locationNumber=9302
elif  [ "${school}" == "Public Relations" ]; then
	school="Public Relations"
	locationNumber=9108
elif  [ "${school}" == "Purcell Elementary" ]; then
	school="Purcell Elementary"
	locationNumber=1141
elif  [ "${school}" == "R. Bruce Wagner Elementary" ]; then
	school="R. Bruce Wagner Elementary"
	locationNumber=0191
elif  [ "${school}" == "Ridge Community Senior" ]; then
	school="Ridge Community Senior"
	locationNumber=0937
elif  [ "${school}" == "Rochelle School of the Arts" ]; then
	school="Rochelle School of the Arts"
	locationNumber=0261
elif  [ "${school}" == "Roosevelt Academy" ]; then
	school="Roosevelt Academy"
	locationNumber=1381
elif  [ "${school}" == "Sandhill Elementary" ]; then
	school="Sandhill Elementary"
	locationNumber=0341
elif  [ "${school}" == "School Technology Services" ]; then
	school="School Technology Services"
	locationNumber=9821
elif  [ "${school}" == "Scott Lake Elementary" ]; then
	school="Scott Lake Elementary"
	locationNumber=1681
elif  [ "${school}" == "Sikes Elementary" ]; then
	school="Sikes Elementary"
	locationNumber=1821
elif  [ "${school}" == "Sleepy Hill Elementary" ]; then
	school="Sleepy Hill Elementary"
	locationNumber=1271
elif  [ "${school}" == "Sleepy Hill Middle" ]; then
	school="Sleepy Hill Middle"
	locationNumber=1971
elif  [ "${school}" == "Snively Elementary" ]; then
	school="Snively Elementary"
	locationNumber=0631
elif  [ "${school}" == "Socrum Elementary" ]; then
	school="Socrum Elementary"
	locationNumber=1901
elif  [ "${school}" == "Southwest Elementary" ]; then
	school="Southwest Elementary"
	locationNumber=0231
elif  [ "${school}" == "Southwest Middle" ]; then
	school="Southwest Middle"
	locationNumber=0051
elif  [ "${school}" == "Spessard L. Holland Elementary" ]; then
	school="Spessard L. Holland Elementary"
	locationNumber=1908
elif  [ "${school}" == "Spook Hill Elementary" ]; then
	school="Spook Hill Elementary"
	locationNumber=1371
elif  [ "${school}" == "Stambaugh Middle" ]; then
	school="Stambaugh Middle"
	locationNumber=0821
elif  [ "${school}" == "Stephens Elementary" ]; then
	school="Stephens Elementary"
	locationNumber=1751
elif  [ "${school}" == "" ]; then
	school="Summerlin Academy"
	locationNumber=0901
elif  [ "${school}" == "Tenoroc Senior" ]; then
	school="Tenoroc Senior"
	locationNumber=1051
elif  [ "${school}" == "Traviss Career Center" ]; then
	school="Traviss Career Center"
	locationNumber=1591
elif  [ "${school}" == "Union Academy" ]; then
	school="Union Academy"
	locationNumber=0971
elif  [ "${school}" == "Valleyview Elementary" ]; then
	school="Valleyview Elementary"
	locationNumber=1891
elif  [ "${school}" == "Wahneta Elementary" ]; then
	school="Wahneta Elementary"
	locationNumber=0681
elif  [ "${school}" == "Wendell Watson Elementary" ]; then
	school="Wendell Watson Elementary"
	locationNumber=1881
elif  [ "${school}" == "Westwood Middle" ]; then
	school="Westwood Middle"
	locationNumber=0571
elif  [ "${school}" == "Winston Academy" ]; then
	school="Winston Academy"
	locationNumber=1251
elif  [ "${school}" == "Winter Haven Senior" ]; then
	school="Winter Haven Senior"
	locationNumber=0481
fi

echo "30% Assigning computer and SAP to user..." >&3
echo "Assigning computer and SAP to user..." 2>&1
/usr/local/jamf/bin/jamf recon -endUsername $clientUser -assetTag $sap

echo "35% Setting ComputerName and HostName..." >&3
echo "Setting ComputerName and HostName" 2>&1

# Change ComputerName and HostName
echo "*** Setting the following paramters:"
echo "*** ComputerName: $school - $sap"
echo "*** HostName: $school - $sap"
/usr/sbin/scutil --set ComputerName "${school} - ${sap}"
/usr/sbin/scutil --set HostName "${school} - ${sap}"

# Change Local Host Name to district standard
computerID="L$locationNumber$environmentLetter-$sap"
echo "Setting LocalHostName to district standard: $computerID" 2>&1
echo "40% Setting LocalHostName..." >&3
echo "Setting LocalHostName" 2>&1
/usr/sbin/scutil --set LocalHostName $computerID
sleep 1

# Attempt to bind to AD
ATTEMPTS=0
MAX_ATTEMPTS=3
SUCCESS=
while [ -z "${SUCCESS}" ]
do
  if [ ${ATTEMPTS} -le ${MAX_ATTEMPTS} ]
  then
    echo "Attempting to bind computer to domain: polk-fl.net..." 2>&1
    echo "45% Attempting to bind to Active Directory..." >&3
    dsconfigad -add "polk-fl.net" -computer "${computerID}" -ou "${COMPUTERS_OU}" -username "${aduser}" -password "${adpass}" -force 2>&1
    IS_BOUND=`dsconfigad -show | grep "Active Directory Domain"`
    if [ -n "${IS_BOUND}" ]
    then
      SUCCESS="YES"
      echo "55% Bind successful!" >&3
      sleep 1
    else
      echo "An error occured while trying to bind this computer to AD. New attempt in 3 seconds..." 2>&1
      echo "45% An error occured while binding to Active Directory. New attempt in 3 seconds..." >&3
      sleep 3
      ATTEMPTS=`expr ${ATTEMPTS} + 1`
    fi
  else
    echo "AD binding failed after ${MAX_ATTEMPTS} attempts." 2>&1
    echo "45% Bind failed!" >&3
    SUCCESS="NO"
  fi
done

# If bind was successful, update AD plugin options
if [ "${SUCCESS}" = "YES" ]; then
  echo "60% Setting Active Directory plugin options..." >&3
  echo "Setting AD plugin options..." 2>&1
  dsconfigad -mobile enable 2>&1
  echo "61% Setting Active Directory plugin options..." >&3
  dsconfigad -mobileconfirm disable 2>&1
  echo "62% Setting Active Directory plugin options..." >&3
  dsconfigad -localhome enable 2>&1
  echo "63% Setting Active Directory plugin options..." >&3
  dsconfigad -useuncpath disable 2>&1
  echo "64% Setting Active Directory plugin options..." >&3
  dsconfigad -protocol smb 2>&1
  echo "65% Setting Active Directory plugin options..." >&3
  dsconfigad -packetsign allow 2>&1
  echo "66% Setting Active Directory plugin options..." >&3
  dsconfigad -packetencrypt allow 2>&1
  echo "67% Setting Active Directory plugin options..." >&3
  dsconfigad -passinterval 0 2>&1
  echo "68% Setting Active Directory plugin options..." >&3
  echo "75% Settings updated!" >&3
  sleep 1

  GROUP_MEMBERS=`dscl /Local/Default -read /Groups/com.apple.access_loginwindow GroupMembers 2>/dev/null`
  NESTED_GROUPS=`dscl /Local/Default -read /Groups/com.apple.access_loginwindow NestedGroups 2>/dev/null`
	  if [ -z "${GROUP_MEMBERS}" ] && [ -z "${NESTED_GROUPS}" ]; then
	    echo "Enabling network users login..." 2>&1
	    echo "80% Enabling network users login..." >&3
	    dseditgroup -o edit -n /Local/Default -a netaccounts -t group com.apple.access_loginwindow 2>/dev/null
	  fi

echo "100% Binding complete!" >&3
sleep 1
exec 3>&-

# wait for all background jobs to exit
rm -f /tmp/hpipe
fi

adminAccount="/Users/administrator"

if [ -d "$adminAccount" ]; then
	echo "Administrator account exists. Ensuring correct password: EERS@$locationNumber"
	dscl . -passwd /Users/administrator "EERS@$locationNumber"
else
	echo "Administrator account does not exist. Creating one with password: EERS@$locationNumber"
	# Create Local Administrator based on Network Segment
	LastID=`dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1`
    NextID=$((LastID + 1))

	dscl . create /Users/administrator
	dscl . create /Users/administrator RealName "Administrator"
	dscl . create /Users/administrator hint "Location"
	dscl . create /Users/administrator picture "/Library/User Pictures/Animals/Eagle.tif"
	dscl . passwd /Users/administrator "EERS@$locationNumber"
	dscl . create /Users/administrator UniqueID $NextID
	dscl . create /Users/administrator PrimaryGroupID 80
	dscl . create /Users/administrator UserShell /bin/bash
	dscl . create /Users/administrator NFSHomeDirectory /Users/administrator
	dscl . -append /Groups/admin GroupMembership administrator
	cp -R /System/Library/User\ Template/English.lproj /Users/administrator
	chown -R administrator:staff /Users/administrator
fi

exit 0