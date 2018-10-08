#!/bin/bash
#
#	Script Name: Active Directory Binder.sh
#	Version: 2.1
#	Last Update: 11/15/2016
#	Requirements:
#		- CocoaDialog
#		- Pashua
#
#	CHANGE HISTORY
#		11/16/16
#			- Updated fallback when ComputerUse could not be defined.
#			- Simplified some school names
#
##################################################

## Get API username, password and license software ID values from script parameters
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
jssURL="$4"
apiuser="$5"
apipass="$6"


# Get computer's Mac Address so that the API can find the correct computer in the JSS database
echo " "
echo "*** Getting Mac address..."
macAddress=`networksetup -getmacaddress en0 | awk '{print $3}' | sed 's/:/./g'`
echo "*** Mac address: ${macAddress}"

# Pull all of the computer's data from JSS
echo "*** Pulling all information about computer from JSS so that data can be extracted later..."
computerFetch=$(curl -sfku ${apiuser}:${apipass} ${jssURL}/JSSResource/computers/macaddress/${macAddress})

# Get the first two segments from both the Ethernet and Wi-Fi adapters.
echo "*** Getting Ethernet and Wifi IP addresses...."
ipEthernet=`ifconfig en0 | grep inet | grep -v inet6 | awk '{print $2}' | cut -c 1-6`
ipWifi=`ifconfig en1 | grep inet | grep -v inet6 | awk '{print $2}' | cut -c 1-6`
echo "*** Ethernet IP: ${ipEthernet}"
echo "*** Wi-Fi IP: ${ipWifi}"


# Set school name and location number based off network segment
echo "*** Setting school based on network segment..."
school=""
locationNumber=""
if [ "${ipEthernet}" = "10.228" ] || [ "${ipWifi}" = "10.228" ]; then
	school="Alta Vista Elementary"
	locationNumber=0331
elif  [ "${ipEthernet}" = "10.186" ] || [ "${ipWifi}" = "10.186" ]; then
	school="Alturas Elementary"
	locationNumber=1041
elif [ "${ipEthernet}" = "10.160" ] || [ "${ipWifi}" = "10.160" ]; then
	school="Auburndale Central Elementary"
	locationNumber=0851
elif [ "${ipEthernet}" = "10.240" ] || [ "${ipWifi}" = "10.240" ]; then
	school="Auburndale Senior"
	locationNumber=0811
#elif [ "${ipEthernet}" = "10.186" ] || [ "${ipWifi}" = "10.186"]; then
#	school="Babson Park Elementary"
elif [ "${ipEthernet}" = "10.172" ] || [ "${ipWifi}" = "10.172" ]; then
	school="Bartow Elemntary"
	locationNumber=0941
elif [ "${ipEthernet}" = "10.166" ] || [ "${ipWifi}" = "10.166" ]; then
	school="Bartow Middle"
	locationNumber=0931
elif [ "${ipEthernet}" = "10.1.3" ] || [ "${ipWifi}" = "10.1.3" ]; then
	school="Bartow Municipal Airport"
	locationNumber=9365
elif [ "${ipEthernet}" = "10.161" ] || [ "${ipWifi}" = "10.161" ]; then
	school="Bartow Senior"
	locationNumber=0901
elif [ "${ipEthernet}" = "10.183" ] || [ "${ipWifi}" = "10.183" ]; then
	school="Ben Hill Griffin Jr Elementary"
	locationNumber=1921
elif [ "${ipEthernet}" = "10.169" ] || [ "${ipWifi}" = "10.169" ]; then
	school="Bethune Academy"
	locationNumber=0391
elif [ "${ipEthernet}" = "10.221" ] || [ "${ipWifi}" = "10.221" ]; then
	school="Bill Duncan Opportunity Center"
	locationNumber=2001
elif [ "${ipEthernet}" = "10.189" ] || [ "${ipWifi}" = "10.189" ]; then
	school="Blake Academy"
	locationNumber=1861
elif [ "${ipEthernet}" = "10.229" ] || [ "${ipWifi}" = "10.229" ]; then
	school="Boone Middle"
	locationNumber=0321
elif [ "${ipEthernet}" = "10.178" ] || [ "${ipWifi}" = "10.178" ]; then
	school="Boswell Elementary"
	locationNumber=1811
elif [ "${ipEthernet}" = "10.170" ] || [ "${ipWifi}" = "10.170" ]; then
	school="Brigham Academy"
	locationNumber=0531
elif [ "${ipEthernet}" = "10.230" ] || [ "${ipWifi}" = "10.230" ]; then
	school="Caldwell Elementary"
	locationNumber=0861
elif [ "${ipEthernet}" = "10.194" ] || [ "${ipWifi}" = "10.194" ]; then
	school="Carlton Palmore Elementary"
	locationNumber=0061
elif [ "${ipEthernet}" = "10.248" ] || [ "${ipWifi}" = "10.248" ]; then
	school="Chain of Lakes Elementary"
	locationNumber=0933
elif [ "${ipEthernet}" = "10.145" ] || [ "${ipWifi}" = "10.145" ]; then
	school="Churchwell Elementary"
	locationNumber=1841
elif [ "${ipEthernet}" = "10.114" ] || [ "${ipWifi}" = "10.114" ]; then
	school="Citrus Ridge Civics Academy"
	locationNumber=1032
elif [ "${ipEthernet}" = "10.146" ] || [ "${ipWifi}" = "10.146" ]; then
	school="Cleveland Court Elementary"
	locationNumber=0081
elif [ "${ipEthernet}" = "10.216" ] || [ "${ipWifi}" = "10.216" ]; then
	school="Combee Elementary"
	locationNumber=0091
elif [ "${ipEthernet}" = "10.231" ] || [ "${ipWifi}" = "10.231" ]; then
	school="Crystal Lake Elementary"
	locationNumber=0101
elif [ "${ipEthernet}" = "10.156" ] || [ "${ipWifi}" = "10.156" ]; then
	school="Crystal Lake Middle"
	locationNumber=1501
elif [ "${ipEthernet}" = "10.245" ] || [ "${ipWifi}" = "10.245" ]; then
	school="Daniel Jenkins Academy"
	locationNumber=0311
elif [ "${ipEthernet}" = "10.223" ] || [ "${ipWifi}" = "10.223" ]; then
	school="Davenport School of the Arts"
	locationNumber=0401
elif [ "${ipEthernet}" = "10.155" ] || [ "${ipWifi}" = "10.155" ]; then
	school="Denison Middle"
	locationNumber=0491
elif [ "${ipEthernet}" = "10.225" ] || [ "${ipWifi}" = "10.225" ]; then
	school="Dixieland Elementary"
	locationNumber=0131
elif [ "${ipEthernet}" = "10.137" ] || [ "${ipWifi}" = "10.137" ]; then
	school="Don Woods Opportunity Center"
	locationNumber=0421
#elif [ "${ipEthernet}" = "10.183" ] || [ "${ipWifi}" = "10.183 "]; then
#	school="Doris A Sanders Learning Center"
#	locationNumber=0092
elif [ "${ipEthernet}" = "10.246" ] || [ "${ipWifi}" = "10.246" ]; then
	school="Dr. N.E. Roberts Elementary"
	locationNumber=1821
elif [ "${ipEthernet}" = "10.149" ] || [ "${ipWifi}" = "10.149" ]; then
	school="Dundee Elementary"
	locationNumber=1781
elif [ "${ipEthernet}" = "10.243" ] || [ "${ipWifi}" = "10.243" ]; then
	school="Dundee Ridge Middle"
	locationNumber=1981
elif [ "${ipEthernet}" = "10.234" ] || [ "${ipWifi}" = "10.234" ]; then
	school="Eagle Lake Elementary"
	locationNumber=1701
elif [ "${ipEthernet}" = "10.235" ] || [ "${ipWifi}" = "10.235" ]; then
	school="East Area Adult School"
	locationNumber=0871
elif [ "${ipEthernet}" = "10.236" ] || [ "${ipWifi}" = "10.236" ]; then
	school="Eastside Elementary"
	locationNumber=0361
elif [ "${ipEthernet}" = "10.237" ] || [ "${ipWifi}" = "10.237" ]; then
	school="Elbert Elementary"
	locationNumber=0591
elif [ "${ipEthernet}" = "10.135" ] || [ "${ipWifi}" = "10.135" ]; then
	school="Floral Avenue Elementary"
	locationNumber=0961
elif [ "${ipEthernet}" = "10.192" ] || [ "${ipWifi}" = "10.192" ]; then
	school="Fort Meade Middle-Senior"
	locationNumber=0791
elif [ "${ipEthernet}" = "10.182" ] || [ "${ipWifi}" = "10.182" ]; then
	school="Frostproof Elementary"
	locationNumber=1291
elif [ "${ipEthernet}" = "10.162" ] || [ "${ipWifi}" = "10.162" ]; then
	school="Frostproof Middle-Senior"
	locationNumber=1801
elif [ "${ipEthernet}" = "10.181" ] || [ "${ipWifi}" = "10.181" ]; then
	school="Garden Grove Elementary"
	locationNumber=1711
elif [ "${ipEthernet}" = "10.202" ] || [ "${ipWifi}" = "10.202" ]; then
	school="Garner Elementary"
	locationNumber=0601
elif [ "${ipEthernet}" = "10.201" ] || [ "${ipWifi}" = "10.201" ]; then
	school="Gause Academy"
	locationNumber=1491
elif [ "${ipEthernet}" = "10.164" ] || [ "${ipWifi}" = "10.164" ]; then
	school="George Jenkins Senior"
	locationNumber=1931
elif [ "${ipEthernet}" = "10.205" ] || [ "${ipWifi}" = "10.205" ]; then
	school="Gibbons Street Elementary"
	locationNumber=0981
elif [ "${ipEthernet}" = "10.185" ] || [ "${ipWifi}" = "10.185" ]; then
	school="Griffin Elementary"
	locationNumber=1231
elif [ "${ipEthernet}" = "10.148" ] || [ "${ipWifi}" = "10.148" ]; then
	school="Haines City Senior"
	locationNumber=1791
elif [ "${ipEthernet}" = "10.121" ] || [ "${ipWifi}" = "10.121" ]; then
	school="Harrison School for the Arts"
	locationNumber=0033
elif [ "${ipEthernet}" = "10.199" ] || [ "${ipWifi}" = "10.199" ]; then
	school="Highland City Elementary"
	locationNumber=1061
elif [ "${ipEthernet}" = "10.130" ] || [ "${ipWifi}" = "10.130" ]; then
	school="Highlands Grove Elementary"
	locationNumber=1281
#elif [ "${ipEthernet}" = "10.183" ] || [ "${ipWifi}" = "10.183 "]; then
#	school="Hillcrest Elementary"
#	locationNumber=0000
elif [ "${ipEthernet}" = "10.210" ] || [ "${ipWifi}" = "10.210" ]; then
	school="Horizons Elementary"
	locationNumber=1362
elif [ "${ipEthernet}" = "10.133" ] || [ "${ipWifi}" = "10.133" ]; then
	school="Inwood Elementary"
	locationNumber=0611
#elif [ "${ipEthernet}" = "10.183" ] || [ "${ipWifi}" = "10.183 "]; then
#	school="Janie Howard Wilson Elementary"
#	locationNumber=0000
elif [ "${ipEthernet}" = "10.123" ] || [ "${ipWifi}" = "10.123" ]; then
	school="Jean O'Dell Learning Center"
	locationNumber=0000
elif [ "${ipEthernet}" = "10.224" ] || [ "${ipWifi}" = "10.224" ]; then
	school="Jesse Keen Elementary"
	locationNumber=1241
elif [ "${ipEthernet}" = "10.204" ] || [ "${ipWifi}" = "10.204" ]; then
	school="Jewett Middle Academy"
	locationNumber=0711
elif [ "${ipEthernet}" = "10.220" ] || [ "${ipWifi}" = "10.220" ]; then
	school="Jewett School of the Arts"
	locationNumber=0712
elif [ "${ipEthernet}" = "10.115" ] || [ "${ipWifi}" = "10.115" ]; then
	school="JMPDC"
	locationNumber=9821
elif [ "${ipEthernet}" = "10.188" ] || [ "${ipWifi}" = "10.188" ]; then
	school="Karen M. Siegal Academy"
	locationNumber=0661
elif [ "${ipEthernet}" = "10.177" ] || [ "${ipWifi}" = "10.177" ]; then
	school="Kathleen Elementary"
	locationNumber=1221
elif [ "${ipEthernet}" = "10.176" ] || [ "${ipWifi}" = "10.176" ]; then
	school="Kathleen Middle"
	locationNumber=1191
elif [ "${ipEthernet}" = "10.175" ] || [ "${ipWifi}" = "10.175" ]; then
	school="Kathleen Senior"
	locationNumber=1181
elif [ "${ipEthernet}" = "10.232" ] || [ "${ipWifi}" = "10.232" ]; then
	school="Kingsford Elementary"
	locationNumber=
elif [ "${ipEthernet}" = "10.198" ] || [ "${ipWifi}" = "10.198" ]; then
	school="Lake Alfred Elementary"
	locationNumber=0651
elif [ "${ipEthernet}" = "10.197" ] || [ "${ipWifi}" = "10.197" ]; then
	school="Lake Alfred-Addair Middle"
	locationNumber=1662
elif [ "${ipEthernet}" = "10.226" ] || [ "${ipWifi}" = "10.226" ]; then
	school="Lake Gibson Middle"
	locationNumber=1761
elif [ "${ipEthernet}" = "10.153" ] || [ "${ipWifi}" = "10.153" ]; then
	school="Lake Gibson Senior"
	locationNumber=1762
elif [ "${ipEthernet}" = "10.128" ] || [ "${ipWifi}" = "10.128" ]; then
	school="Lake Marion Creek Middle"
	locationNumber=1831
elif [ "${ipEthernet}" = "10.163" ] || [ "${ipWifi}" = "10.163" ]; then
	school="Lake Region Senior"
	locationNumber=1991
elif [ "${ipEthernet}" = "10.206" ] || [ "${ipWifi}" = "10.206" ]; then
	school="Lake Shipp Elementary"
	locationNumber=0621
elif [ "${ipEthernet}" = "10.174" ] || [ "${ipWifi}" = "10.174" ]; then
	school="Lake Wales Senior"
	locationNumber=1721
elif [ "${ipEthernet}" = "10.195" ] || [ "${ipWifi}" = "10.195" ]; then
	school="Lakeland Highlands Middle"
	locationNumber=1771
elif [ "${ipEthernet}" = "10.158" ] || [ "${ipWifi}" = "10.158" ]; then
	school="Lakeland Senior"
	locationNumber=0031
elif [ "${ipEthernet}" = "10.126" ] || [ "${ipWifi}" = "10.126" ]; then
	school="Laurel Elementary"
	locationNumber=1611
elif [ "${ipEthernet}" = "10.173" ] || [ "${ipWifi}" = "10.173" ]; then
	school="Lawton Chiles Middle Academy"
	locationNumber=0043
elif [ "${ipEthernet}" = "10.222" ] || [ "${ipWifi}" = "10.222" ]; then
	school="Lena Vista Elementary"
	locationNumber=0841
elif [ "${ipEthernet}" = "10.217" ] || [ "${ipWifi}" = "10.217" ]; then
	school="Lewis Anna Woodbury Elementary - Lewis Campus"
	locationNumber=0771
elif [ "${ipEthernet}" = "10.212" ] || [ "${ipWifi}" = "10.212" ]; then
	school="Lewis Anna Woodbury Elementary - Lewis Campus"
	locationNumber=0771
elif [ "${ipEthernet}" = "10.144" ] || [ "${ipWifi}" = "10.144" ]; then
	school="Lincoln Avenue Academy"
	locationNumber=0251
elif [ "${ipEthernet}" = "10.138" ] || [ "${ipWifi}" = "10.138" ]; then
	school="Loughman Oaks Elementary"
	locationNumber=1941
#elif [ "${ipEthernet}" = "10.183" ] || [ "${ipWifi}" = "10.183 "]; then
#	school="McKeel Academy"
elif [ "${ipEthernet}" = "10.167" ] || [ "${ipWifi}" = "10.167" ]; then
	school="McLaughlin Middle"
	locationNumber=1341
elif [ "${ipEthernet}" = "10.193" ] || [ "${ipWifi}" = "10.193" ]; then
	school="Medulla Elementary"
	locationNumber=0181
elif [ "${ipEthernet}" = "10.179" ] || [ "${ipWifi}" = "10.179" ]; then
	school="Mulberry Middle"
	locationNumber=1161
elif [ "${ipEthernet}" = "10.159" ] || [ "${ipWifi}" = "10.159" ]; then
	school="Mulberry Senior"
	locationNumber=1131
elif [ "${ipEthernet}" = "10.215" ] || [ "${ipWifi}" = "10.215" ]; then
	school="North Lakeland Elementary"
	locationNumber=0201
elif [ "${ipEthernet}" = "10.239" ] || [ "${ipWifi}" = "10.239" ]; then
	school="Oscar J Pope Elementary"
	locationNumber=1521
elif [ "${ipEthernet}" = "10.147" ] || [ "${ipWifi}" = "10.147" ]; then
	school="Padgett Elementary"
	locationNumber=1451
elif [ "${ipEthernet}" = "10.129" ] || [ "${ipWifi}" = "10.129" ]; then
	school="Palmetto Elementary"
	locationNumber=1702
elif [ "${ipEthernet}" = "10.227" ] || [ "${ipWifi}" = "10.227" ]; then
	school="Philip O'Brien Elementary"
	locationNumber=0151
elif [ "${ipEthernet}" = "10.184" ] || [ "${ipWifi}" = "10.184" ]; then
	school="Pinewood Elementary"
	locationNumber=1731
#elif [ "${ipEthernet}" = "10.183" ] || [ "${ipWifi}" = "10.183 "]; then
#	school="polk Avenue Elementary"
#	locationNumber=1351
elif [ "${ipEthernet}" = "10.200" ] || [ "${ipWifi}" = "10.200" ]; then
	school="Polk City Elementary"
	locationNumber=0881
#elif [ "${ipEthernet}" = "10.x" ] || [ "${ipWifi}" = "10.x" ]; then
#	school="Polk Life and Learning Center"
#	locationNumber=0962
elif [ "${ipEthernet}" = "10.132" ] || [ "${ipWifi}" = "10.132" ]; then
	school="Purcell Elementary"
	locationNumber=1141
elif [ "${ipEthernet}" = "10.247" ] || [ "${ipWifi}" = "10.247" ]; then
	school="R. Bruce Wagner Elementary"
	locationNumber=0191
elif [ "${ipEthernet}" = "10.249" ] || [ "${ipWifi}" = "10.249" ]; then
	school="Ridge Community Senior"
	locationNumber=0937
elif [ "${ipEthernet}" = "10.208" ] || [ "${ipWifi}" = "10.208" ]; then
	school="Rochelle School of the Arts"
	locationNumber=0261
elif [ "${ipEthernet}" = "10.219" ] || [ "${ipWifi}" = "10.219" ]; then
	school="Roosevelt Academy"
	locationNumber=1381
elif [ "${ipEthernet}" = "10.142" ] || [ "${ipWifi}" = "10.142" ]; then
	school="Sandhill Elementary"
	locationNumber=0341
elif [ "${ipEthernet}" = "10.187" ] || [ "${ipWifi}" = "10.187" ]; then
	school="Scott Lake Elementary"
	locationNumber=1681
elif [ "${ipEthernet}" = "10.213" ] || [ "${ipWifi}" = "10.213" ]; then
	school="Sikes Elementary"
	locationNumber=1821
elif [ "${ipEthernet}" = "10.131" ] || [ "${ipWifi}" = "10.131" ]; then
	school="Sleepy Hill Elementary"
	locationNumber=1271
elif [ "${ipEthernet}" = "10.244" ] || [ "${ipWifi}" = "10.244" ]; then
	school="Sleepy Hill Middle"
	locationNumber=1971
elif [ "${ipEthernet}" = "10.191" ] || [ "${ipWifi}" = "10.191" ]; then
	school="Snively Elementary"
	locationNumber=0631
elif [ "${ipEthernet}" = "10.134" ] || [ "${ipWifi}" = "10.134" ]; then
	school="Socrum Elementary"
	locationNumber=1901
elif [ "${ipEthernet}" = "10.141" ] || [ "${ipWifi}" = "10.141" ]; then
	school="Southwest Elementary"
	locationNumber=0231
elif [ "${ipEthernet}" = "10.140" ] || [ "${ipWifi}" = "10.140" ]; then
	school="Southwest Middle"
	locationNumber=0051
elif [ "${ipEthernet}" = "10.211" ] || [ "${ipWifi}" = "10.211" ]; then
	school="Spessard L. Holland Elementary"
	locationNumber=1908
elif [ "${ipEthernet}" = "10.151" ] || [ "${ipWifi}" = "10.151" ]; then
	school="Spook Hill Elementary"
	locationNumber=1371
elif [ "${ipEthernet}" = "10.171" ] || [ "${ipWifi}" = "10.171" ]; then
	school="Stambaugh Middle"
	locationNumber=0821
elif [ "${ipEthernet}" = "10.209" ] || [ "${ipWifi}" = "10.209" ]; then
	school="Stephens Elementary"
	locationNumber=1751
#elif [ "${ipEthernet}" = "10.x" ] || [ "${ipWifi}" = "10.x" ]; then
#	school="Summerlin Academy"
#	locationNumber=0000
elif [ "${ipEthernet}" = "10.139" ] || [ "${ipWifi}" = "10.139" ]; then
	school="Tenoroc Senior"
	locationNumber=1051
elif [ "${ipEthernet}" = "10.152" ] || [ "${ipWifi}" = "10.152" ]; then
	school="Traviss Career Center"
	locationNumber=1591
elif [ "${ipEthernet}" = "10.207" ] || [ "${ipWifi}" = "10.207" ]; then
	school="Union Academy"
	locationNumber=0971
elif [ "${ipEthernet}" = "10.154" ] || [ "${ipWifi}" = "10.154" ]; then
	school="Valleyview Elementary"
	locationNumber=1891
elif [ "${ipEthernet}" = "10.136" ] || [ "${ipWifi}" = "10.136" ]; then
	school="Wahneta Elementary"
	locationNumber=0681
elif [ "${ipEthernet}" = "10.241" ] || [ "${ipWifi}" = "10.241" ]; then
	school="Wendell Watson Elementary"
	locationNumber=1881
#elif [ "${ipEthernet}" = "10.x" ] || [ "${ipWifi}" = "10.x" ]; then
#	school="West Area Adult School"
#	locationNumber=0000
elif [ "${ipEthernet}" = "10.242" ] || [ "${ipWifi}" = "10.242" ]; then
	school="Westwood Middle"
	locationNumber=0571
elif [ "${ipEthernet}" = "10.143" ] || [ "${ipWifi}" = "10.143" ]; then
	school="Winston Academy of Engineering"
	locationNumber=1251
elif [ "${ipEthernet}" = "10.157" ] || [ "${ipWifi}" = "10.157" ]; then
	school="Winter Haven Senior"
	locationNumber=0481
else
	# Computer is most likely behind a home router. As a fallback, extract building information from computerFetch variable
	school=$(awk -F'<building>|</building>' '{print $2}' <<< $computerFetch)

		# If no building is selected, set school to Unknown
		if [ "${school}" = "" ]; then
			school="Unknown"
			locationNumber=0000
		else
			# Set Location Number based on school name
			echo "*** Assigning location number to school..."
			case $school in
				"Alta Vista Elementary") locationNumber=0331;;
				"Alturas Elementary") locationNumber=1041;;
				"Auburndale Central Elementary") locationNumber=0851;;
				"Auburndale Senior") locationNumber=0811;;
				"Babson Park Elementary") locationNumber=1421;;
				"Bartow Elementary") locationNumber=0941;;
				"Bartow Middle") locationNumber=0931;;
				"Bartow Municipal Airport") locationNumber=9365;;
				"Bartow Senior") locationNumber=0901;;
				"Ben Hill Griffin Jr Elementary") locationNumber=1921;;
				"Bethune Academy") locationNumber=0391;;
				"Bill Duncan Opportunity Center") locationNumber=2001;;
				"Blake Academy") locationNumber=1861;;
				"Boone Middle") locationNumber=0321;;
				"Boswell Elementary") locationNumber=1811;;
				"Brigham Academy") locationNumber=0531;;
				"Caldwell Elementary") locationNumber=0861;;
				"Carlton Palmore Elementary") locationNumber=0061;;
				"Chain of Lakes Elementary") locationNumber=0933;;
				"Churchwell Elementary") locationNumber=1841;;
				"Citrus Ridge Civics Academy") locationNumber=1032;;
				"Cleveland Court Elementary") locationNumber=0081;;
				"Combee Elementary") locationNumber=0091;;
				"Crystal Lake Elementary") locationNumber=0101;;
				"Crystal Lake Middle") locationNumber=1501;;
				"Daniel Jenkins Academy") locationNumber=0311;;
				"Davenport School of the Arts") locationNumber=0401;;
				"Denison Middle") locationNumber=0491;;
				"District Office") locationNumber=9821;;
				"Dixieland Elementary") locationNumber=0131;;
				"Doris A Sanders Learning Center") locationNumber=0092;;
				"Don Woods Opportunity Center") locationNumber=0421;;
				"Dr. N.E. Roberts Elementary") locationNumber=;;
				"Dundee Elementary") locationNumber=1781;;
				"Dundee Ridge Middle") locationNumber=1981;;
				"Eagle Lake Elementary") locationNumber=0591;;
				"East Area Adult School") locationNumber=0871;;
				"Eastside Elementary") locationNumber=0361;;
				"Elbert Elementary") locationNumber=0591;;
				"Floral Avenue Elementary") locationNumber=0961;;
				"Fort Meade Middle-Senior") locationNumber=0791;;
				"Frostproof Elementary") locationNumber=1291;;
				"Frostproof Middle-Senior") locationNumber=1801;;
				"Garden Grove Elementary") locationNumber=1711;;
				"Garner Elementary") locationNumber=0601;;
				"Gause Academy") locationNumber=1491;;
				"George Jenkins Senior") locationNumber=1931;;
				"Gibbons Street Elementary") locationNumber=0981;;
				"Griffin Elementary") locationNumber=1231;;
				"Haines City Senior") locationNumber=1791;;
				"Harrison School for the Arts") locationNumber=0033;;
				"Highland City Elementary") locationNumber=1061;;
				"Highlands Grove Elementary") locationNumber=1281;;
				"Hillcrest Elementary") locationNumber=1361;;
				"Horizons Elementary") locationNumber=1362;;
				"Inwood Elementary") locationNumber=0611;;
				"Janie Howard Wilson Elementary") locationNumber=1401;;
				"Jean O'Dell Learning Center") locationNumber=0962;;
				"Jesse Keen Elementary") locationNumber=1241;;
				"Jewett Middle Academy") locationNumber=0711;;
				"Jewett School of the Arts") locationNumber=0712;;
				"JMPDC") locationNumber=9821;;
				"Karen M. Siegel Academy") locationNumber=0661;;
				"Kathleen Elementary") locationNumber=1221;;
				"Kathleen Middle") locationNumber=1191;;
				"Kathleen Senior") locationNumber=1181;;
				"Kingsford Elementary") locationNumber=1151;;
				"Lake Alfred Elementary") locationNumber=0651;;
				"Lake Alfred-Addair Middle") locationNumber=1662;;
				"Lake Gibson Middle") locationNumber=1761;;
				"Lake Gibson Senior") locationNumber=1762;;
				"Lake Marion Creek Middle") locationNumber=1831;;
				"Lake Region Senior") locationNumber=1991;;
				"Lake Shipp Elementary") locationNumber=0621;;
				"Lake Wales Senior") locationNumber=1721;;
				"Lakeland Highlands Middle") locationNumber=1771;;
				"Lakeland Senior") locationNumber=0031;;
				"Laurel Elementary") locationNumber=1611;;
				"Lawton Chiles Middle Academy") locationNumber=0043;;
				"Lena Vista Elementary") locationNumber=0841;;
				"Lewis Anna Woodbury Elementary - Lewis Campus") locationNumber=0802;;
				"Lincoln Avenue Academy") locationNumber=0251;;
				"Loughman Oaks Elementary") locationNumber=1941;;
				"McKeel Academt") locationNumber=1671;;
				"McKeel Academy") locationNumber=1671;;
				"McKeel Academy of Technology") locationNumber=1671;;
				"McLaughlin Middle") locationNumber=1341;;
				"Medulla Elementary") locationNumber=0181;;
				"Mulberry Middle") locationNumber=1161;;
				"Mulberry Senior") locationNumber=1131;;
				"North Lakeland Elementary") locationNumber=0201;;
				"Oscar J Pope Elementary") locationNumber=1521;;
				"Padgett Elementary") locationNumber=1451;;
				"Palmetto Elementary") locationNumber=1702;;
				"Philip O'Brien Elementary") locationNumber=0151;;
				"Pinewood Elementary") locationNumber=1731;;
				"Polk City Elementary") locationNumber=0881;;
				"Purcell Elementary") locationNumber=1141;;
				"R. Bruce Wagner Elementary") locationNumber=0191;;
				"Ridge Career Center") locationNumber=0937;;
				"Ridge Community Senior") locationNumber=0937;;
				"Rochelle School of the Arts") locationNumber=0261;;
				"Roosevelt Academy") locationNumber=1381;;
				"Sandhill Elementary") locationNumber=0341;;
				"Scott Lake Elementary") locationNumber=1681;;
				"Sikes Elementary") locationNumber=1821;;
				"Sleepy Hill Elementary") locationNumber=1271;;
				"Sleepy Hill Middle") locationNumber=1971;;
				"Snively Elementary") locationNumber=0631;;
				"Socrum Elementary") locationNumber=1901;;
				"Southwest Elementary") locationNumber=0231;;
				"Southwest Middle") locationNumber=0051;;
				"Spessard L. Holland Elementary") locationNumber=1908;;
				"Spook Hill Elementary") locationNumber=1371;;
				"Stambaugh Middle") locationNumber=0821;;
				"Stephens Elementary") locationNumber=1751;;
				"Summerlin Academy") locationNumber=0905;;
				"Tenoroc Senior") locationNumber=1051;;
				"Union Academy") locationNumber=0971;;
				"Valleyview Elementary") locationNumber=1891;;
				"Wahneta Elementary") locationNumber=0681;;
				"Wendell Watson Elementary") locationNumber=1881;;
				"West Area Adult School") locationNumber=0071;;
				"Westwood Middle") locationNumber=0571;;
				"Winston Academy of Engineering") locationNumber=1251;;
				"Winter Haven Senior") locationNumber=0481;;
				"Unknown") locationNumber=0000;;
				*) locationNumber=0000;;
			esac
		fi
fi

echo "*** Retrieved school: ${school}"
echo "*** Decided on location number: ${locationNumber}"


# Pull the current Asset Tag from JSS API
echo "*** Extracting Asset Tag information from computerFetch variable..."
assetTag=$(awk -F'<asset_tag>|</asset_tag>' '{print $2}' <<< $computerFetch)


# If no Asset Tag, use the serial number
if [ "$assetTag" = "" ]; then
    assetTag=`ioreg -c "IOPlatformExpertDevice" | awk -F '"' '/IOPlatformSerialNumber/ {print $4}'`
fi
echo "*** Retrieved Asset Tag: ${assetTag}"


# Change ComputerName and HostName
echo "*** Setting the following paramters:"
echo "*** ComputerName: $school - $assetTag"
echo "*** HostName: $school - $assetTag"
/usr/sbin/scutil --set ComputerName "${school} - ${assetTag}"
/usr/sbin/scutil --set HostName "${school} - ${assetTag}"

# Check to see if computer is already bound to PCSB AD
echo "*** Checking for Active Directory domain so that LocalHostName can be set..."
domain=`dsconfigad -show | grep "Active Directory Domain" | awk '{print $5}'`

# If already bound, grab the computer use definition (Admin, Teacher, Lab, or Student) to append to name.
if [ "${domain}" = "polk-fl.net" ]; then
	echo "*** Domain found: ${domain}"
	computerUse=`scutil --get LocalHostName | cut -c 6`

	if [ "${computerUse}" = "-" ] || [ "${computerUse}" = "" ]; then
		echo "*** Setting LocalHostName to L${locationNumber}S-${assetTag}"
		/usr/sbin/scutil --set LocalHostName "L${locationNumber}S-${assetTag}"
	else
		echo "*** Setting LocalHostName to L${locationNumber}${computerUse}-${assetTag}"
		/usr/sbin/scutil --set LocalHostName "L${locationNumber}${computerUse}-${assetTag}"
	fi
else
	echo "*** Domain found: Not Bound"
	echo "*** Setting LocalHostName to L${locationNumber}S-${assetTag}"
	/usr/sbin/scutil --set LocalHostName "L${locationNumber}S-${assetTag}"
fi

# Get computer ID from computerFetch variable
#echo "*** Retrieving Computer ID from JSS..."
#computerID=$(awk -F'<id>|</id>' '{print $2}' <<< $computerFetch)
#echo "*** Computer ID: ${computerID}"

# Using computer ID, submit the new school to the Building field of the JSS
#echo "*** Submitting updated building info to JSS..."

exit 0