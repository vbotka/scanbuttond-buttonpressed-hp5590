#!/bin/bash

# Script to switch the email address. Example:
# ssh saned@srv "/etc/scanbuttond/switch-email.sh 2

EMAIL[1]="user1@example.org"
EMAIL[2]="user2@example.org"
EMAIL[3]="user3@example.org"

NEW=${EMAIL[$1]}
# printf "switching to $NEW\n"

sed -r -i "s/EMAIL=.*/EMAIL=$NEW/" /etc/scanbuttond/buttonpressed.sh
exit
