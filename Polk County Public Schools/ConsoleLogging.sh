#!/bin/bash

logFile="/var/log/com.pcps.registration.log"

# Check for / create logFile
if [ ! -f "${logFile}" ]; then
    # logFile not found; Create logFile
    /usr/bin/touch "${logFile}"
fi


function ScriptLog() { # Re-direct logging to the log file ...

    exec 3>&1 4>&2        # Save standard output and standard error
    exec 1>>"${logFile}"    # Redirect standard output to logFile
    exec 2>>"${logFile}"    # Redirect standard error to logFile

    NOW=`date +%Y-%m-%d\ %H:%M:%S`    
    /bin/echo "${NOW}" " ${1}" >> ${logFile}

}

function jssLog() { # Re-direct logging to the JSS

    ScriptLog "${1}"

    exec 1>&3 2>&4
    /bin/echo >&1 ${1}

}

ScriptLog "test 1"