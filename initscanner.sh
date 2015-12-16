#!/bin/bash

# This script is executed whenever scanbuttond
# finds new devices.

LOG="/var/log/sane-buttonpressed.log"
DEVICE=$(scanimage -L)

printf "initscanner.sh: $DEVICE \n" >> $LOG
exit
