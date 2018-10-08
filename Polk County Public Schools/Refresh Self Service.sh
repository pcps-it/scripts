#!/bin/bash
#
#	Script Name: Refresh Self Service.sh
#	Version: 1.0
#	Last Update: 10/12/2016
#
##################################################

#grep for Self Service if empty string then it is not running
#[Ss] regular expression trick keeps this grep from seeing itself in ps list
if [ -z "$(ps auxww | grep "[Ss]elf Service.app")" ]; then
echo "Self Service not open, exiting"
fi

#get name of console owner
eval $(stat -s /dev/console)
consoleUsername=$(id -un $st_uid)

#run as console user
sudo su $consoleUsername -c "open selfservice://policy="

exit 0