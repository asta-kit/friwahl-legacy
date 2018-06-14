#!/bin/bash
#
# Trouble System for the UStA Wahl
#
# (c) 2005-2006 by Fabian Franz
# (c) 2008-2012 by Mario Prausa
# (c) 2016-2018 by Andrej Rode
#
# License: GPL, version 2
#
# $Id: verwaltung.sh 401 2011-01-09 18:33:05Z mariop $
#

# Dependencies: expect, fping

export TERM=linux

. /etc/profile

cd $(dirname $0)


STATUSFILE=/tmp/wahl-status
TIMEFILE=/tmp/timefile.tmp
SERVER=$(cat /etc/friwahl/server)
COMMON_DIALOG_OPTIONS="--title "Status" --begin 2 5 --tailboxbg "$STATUSFILE" 4 78 --and-widget --title "Uhrzeit" --begin 29 5 --tailboxbg "$TIMEFILE" 4 35"
export BACKTITLE="VS-Wahlen 2018 - Verwaltung"

# Accountdaten einlesen
. /etc/friwahl/rzaccount.sh

function wkit_guest
{
	for devdir in /sys/class/net/*; do
		if [ `cat $devdir/type` = "1" ]; then
		if [ -d "$devdir/wireless" ]; then
		WLDEV=`echo $devdir | sed "s|/sys/class/net/||g"`
		break
		fi
		fi
	done

	if [ -z "$WLDEV" ]; then
	dialog --backtitle "$BACKTITLE" --title "automatische wKIT/WPA-Einwahl" --timeout 10 --msgbox "keine WLAN-Karte gefunden" 0 0
	return
	fi

	killall wpa_supplicant 2> /dev/null
	sleep 2

	sed "s|__rzaccount__|$RZACCOUNT@kit.edu|g;s|__rzpassword__|${RZPASSWORD/&/\\&}|g" /etc/wpa_supplicant.conf0 > /tmp/wpa_supplicant.conf
	wpa_supplicant -c /tmp/wpa_supplicant.conf -i$WLDEV -B

	echo
	echo -n "Suche Netz auf $WLDEV ..."

	dhclient $WLDEV || { echo "fehlgeschlagen"; echo "Beliebige Taste um fortzufahren."; read -n1; exit 1; }

	echo "OK"
}

function wkit_gui
{
	for devdir in /sys/class/net/*; do
		if [ `cat $devdir/type` = "1" ]; then
			if [ -d "$devdir/wireless" ]; then
				WLDEV=`echo $devdir | sed "s|/sys/class/net/||g"`
				break
			fi
		fi
	done

	if [ -z "$WLDEV" ]; then
		dialog --backtitle "$BACKTITLE" --title "wKIT/WPA-Einwahl" --timeout 10 --msgbox "keine WLAN-Karte gefunden" 0 0
		return
	fi

	echo -n "Username: "
	read WPA_USER || return
	echo -n "Password: "
	read -s WPA_PASSWORD || return

	killall wpa_supplicant 2> /dev/null
	sleep 2

	sed "s|__rzaccount__|$WPA_USER|g;s|__rzpassword__|${WPA_PASSWORD/&/\\&}|g" /etc/wpa_supplicant.conf0 > /tmp/wpa_supplicant.conf
	wpa_supplicant -c /tmp/wpa_supplicant.conf -i$WLDEV -B

	echo
	echo -n "Suche Netz auf $WLDEV ..."

	dhclient $WLDEV || { echo "fehlgeschlagen"; echo "Beliebige Taste um fortzufahren."; read -n1; exit 1; }

	echo "OK"
}

function pause
{
	echo "Beliebige Taste um fortzufahren."
	read -n1
}

killall uhrzeit.sh 2> /dev/null
killall status.sh 2> /dev/null
./uhrzeit.sh &
./status.sh &

while true;
do
	CHOICE=$(dialog $COMMON_DIALOG_OPTIONS --and-widget --stdout --nocancel --backtitle "$BACKTITLE" --title "Problemlösung" --menu "Auswahl" 0 40 5 "1" "automatisches Verbinden" "2" "automatische Einwahl wKIT" "3" "manuelle Einwahl wKIT") || { CHOICE="-1"; reset -I; }

	case "$CHOICE"
	in
		1)
			./netsetup.sh -x
		;;
		2)
			wkit_guest
		;;
		3)
			wkit_gui
		;;
	esac
done
