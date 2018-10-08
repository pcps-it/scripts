#!/bin/bash

serialNumber=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Serial\ Number\ \(system\)/ {print $NF}'`

if [ $serialNumber == "C07PM21TG1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 01 - 50015224"
fi

if [ $serialNumber == "C07PM0HSG1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 02 - 50015214"
fi

if [ $serialNumber == "C07PM0JBG1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 03 - 50015215"
fi

if [ $serialNumber == "C07PM215G1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 04 - 50015222"
fi

if [ $serialNumber == "C07PM0MTG1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 05 - 50015218"
fi

if [ $serialNumber == "C07PM0FCG1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 06 - 50015212"
fi

if [ $serialNumber == "C07PM216G1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 07 - 50015223"
fi

if [ $serialNumber == "C07PM22BG1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 08 - 50015225"
fi

if [ $serialNumber == "C07PM0N6G1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 09 - 50015219"
fi

if [ $serialNumber == "C07PM20QG1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 10 - 50015221"
fi

if [ $serialNumber == "C07PM0DTG1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 11 - 50015210"
fi

if [ $serialNumber == "C07PM0LWG1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 12 - 50015216"
fi

if [ $serialNumber == "C07PM0MRG1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 13 - 50015217"
fi

if [ $serialNumber == "C07PM0N7G1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 14 - 50015220"
fi

if [ $serialNumber == "C07PM0FFG1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 15 - 50015213"
fi

if [ $serialNumber == "C07PM2GPG1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 16 - 50015227"
fi

if [ $serialNumber == "C07PM22GG1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 17 - 50015226"
fi

if [ $serialNumber == "C07PM0DWG1J1" ]; then
    /usr/sbin/scutil --set ComputerName "Palmetto Lab - 18 - 50015211"
fi

jamf recon
exit 0