#!/bin/bash
## Turn off high powered USB mode
nvram -d usb-options

## Create inventory file
rm /Library/PCPS/resources/usbmodeon