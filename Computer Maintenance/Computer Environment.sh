#!/bin/bash

# Determins if the computer is setup for Admins, Labs, Students, or Teachers
# so that policies can be scoped to specific user groups.

localHostName=`scutil --get LocalHostName | head -c 6 | tail -c 1`

computerRole=""
case "$localHostName" in
	"A"|"a")
		computerRole="Administrator"
		;;
	"L"|"l")
		computerRole="Lab"
		;;
	"S"|"s")
		computerRole="Student"
		;;
	"T"|"t")
		computerRole="Teacher"
		;;
	*)
		computerRole="Unknown"
		;;
esac

echo "<result>$computerRole</result>"


exit 0