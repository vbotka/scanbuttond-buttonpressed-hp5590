#!/bin/bash
#
# Started by scanbuttond. Example:
# sh -c /etc/scanbuttond/buttonpressed.sh 1 hp5590:libusb:001:010
#
# This script is started by scanbuttond whenever a scanner button has been pressed.
# Scanbuttond passes the following parameters to us:
# $1 ... the button number
# $2 ... the scanner's SANE device name

LOG="/var/log/sane-buttonpressed.log"
BUTTON=$1
DEVICE=$2
printf "buttonpressed.sh: Button $BUTTON pressed on device $DEVICE\n" >> $LOG

FORMAT="pnm"
NAME=$(date +"%Y-%m-%d_%H-%M-%S")
LOCKFILE="/tmp/scanbuttonpressed"
A2PSPAR="--portrait --columns=1 --rows=1 --no-header --medium=A4"
PRINTER_BW="printer-bw"
PRINTER_COLOR="printer-color"
EMAIL=user1@example.org

function remove {
    rm -rf /tmp/$NAME
    printf "buttonpressed.sh: /tmp/$NAME removed\n" >> $LOG
    lockfile-remove $LOCKFILE
    printf "buttonpressed.sh: $LOCKFILE.lock removed\n" >> $LOG
}

function test {
    if [ $? != 0 ]; then
	printf "buttonpressed.sh: ERROR: Command failed\n" >> $LOG
	remove
	exit 1
    fi
}

function scan {
    printf "buttonpressed.sh: Scan started\n" >> $LOG
    scanimage -d $DEVICE -y 297mm -x 210mm  --format=$FORMAT --mode $MODE --resolution $RESOLUTION --source ADF --batch
}

function pnm_to_jpg {
    for i in *.pnm; do
	convert -quality $QUALITY $i $i.jpg
	printf "buttonpressed.sh: $i converted to $i.jpg\n" >> $LOG
    done
}

# Main
if !(lockfile-create --retry 2 $LOCKFILE); then
    printf "buttonpressed.sh: Lockfile $LOCKFILE found: Scanning already in progress for $2?" >> $LOG
    exit 1
fi

mkdir /tmp/$NAME
printf "buttonpressed.sh: /tmp/$NAME created\n" >> $LOG
cd /tmp/$NAME
printf "buttonpressed.sh: working directory /tmp/$NAME\n" >> $LOG

case $BUTTON in
    1)  # copy BW
	RESOLUTION="300"
	MODE="Gray"
	scan
	convert -page A4 *.pnm $NAME.pdf
	printf "buttonpressed.sh: print $NAME.pdf on $PRINTER_BW\n" >> $LOG
	cat $NAME.pdf | a2ps $A2PSPAR -P$PRINTER_BW
	;;
    2)  # copy Color
	RESOLUTION="300"
	MODE="Color"
	scan
	convert -page A4 *.pnm $NAME.pdf
	printf "buttonpressed.sh: print $NAME.pdf on $PRINTER_COLOR\n" >> $LOG
	cat $NAME.pdf | a2ps $A2PSPAR -P$PRINTER_COLOR
	;;
    3)  # mail Lineart
	RESOLUTION="200"
	MODE="Lineart"
	QUALITY="10"
	scan
	pnm_to_jpg
	convert -page A4 *.jpg $NAME.pdf
	printf "buttonpressed.sh: mail $NAME.pdf to $EMAIL\n" >> $LOG
	echo "scanner $NAME" | mail -A $NAME.pdf -s "scanner $NAME" $EMAIL
	;;
    4)  # mail Gray
	RESOLUTION="200"
	MODE="Gray"
	QUALITY="10"
	scan
	pnm_to_jpg
	convert -page A4 *.jpg $NAME.pdf
	printf "buttonpressed.sh: mail $NAME.pdf to $EMAIL\n" >> $LOG
	echo "scanner $NAME" | mail -A $NAME.pdf -s "scanner $NAME" $EMAIL
	;;
    5)  # mail Color
	RESOLUTION="200"
	MODE="Color"
	QUALITY="10"
	scan
	pnm_to_jpg
	convert -page A4 *.jpg $NAME.pdf
	printf "buttonpressed.sh: mail $NAME.pdf to $EMAIL\n" >> $LOG
	echo "scanner $NAME" | mail -A $NAME.pdf -s "scanner $NAME" $EMAIL
	;;
esac

remove
exit
