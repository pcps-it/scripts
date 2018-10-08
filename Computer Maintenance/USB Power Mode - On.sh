#!/bin/bash
## Turn on high powered USB mode
nvram usb-options="%01%00%00%00"

## Create inventory file
touch /Library/PCPS/resources/usbmodeon