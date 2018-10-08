#!/bin/sh
sudo /usr/local/bin/jamf -removeFramework

sudo /usr/bin/dscl . -delete /Users/jamfadmin

sudo /bin/rm -rf /Users/jamfadmin

sudo /bin/rm -rf /var/jamfadmin

exit 0