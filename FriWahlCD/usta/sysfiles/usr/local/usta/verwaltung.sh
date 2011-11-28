#!/bin/bash
# 
# Trouble System for the UStA Wahl 
#
# (c) 2005-2006 by Fabian Franz
# (c) 2008-2010 by Mario Prausa
#
# License: GPL, version 2
#
# $Id: verwaltung.sh 401 2011-01-09 18:33:05Z mariop $
#

# Dependencies: expect, vpnc-login, fping

cd $(dirname $0)

export LANG=de_DE.utf8

STATUSFILE=/tmp/wahl-status
TIMEFILE=/tmp/timefile.tmp
SERVER=$(cat /etc/friwahl/server)
export BACKTITLE="UStA Wahl 2011 - Verwaltung"

# Accountdaten einlesen
. /etc/friwahl/rzaccount.sh

function vpnc_gui
{
	[ -e /var/run/vpnc/pid ] && vpnc-disconnect
	VPNC_ERROR=""
	killall vpnc
	if [ "$1" = "manual" ]
	then
		echo -n "Username: "
		read VPNC_USER || return
		echo -n "Password: "
		read -s VPNC_PASSWORD || return
		echo "user=$VPNC_USER#pass=$VPNC_PASSWORD" | ./vpnc-login /etc/vpnc/vpnc.conf
	else
		echo -e "user=$RZACCOUNT#pass=$RZPASSWORD" | ./vpnc-login /etc/vpnc/vpnc.conf
	fi
	case $? in
		0)
			# all ok
		;;
		1)
			VPNC_ERROR="Authentification fehlgeschlagen."
		;;
		3)
			VPNC_ERROR="VPNC läuft schon."
		;;
		4)
			VPNC_ERROR="VPNC läuft nicht als root."
		;;
		*)
			VPNC_ERROR="Unbekannter Fehler."
		;;
			
	esac
	unset VPNC_PASSWORD
	unset VPNC_USER
	sleep 1
	[ -n "$VPNC_ERROR" ] && dialog --backtitle "$BACKTITLE" --title "VPN-Einwahl fehlgeschlagen" --timeout 10 --msgbox "$VPNC_ERROR" 0 0 || reset -I
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
		dialog --backtitle "$BACKTITLE" --title "wKIT/WPA Einwahl" --timeout 10 --msgbox "keine WLAN Karte gefunden" 0 0
		return
	fi

	echo -n "Username: "
	read WPA_USER || return
	echo -n "Password: "
	read -s WPA_PASSWORD || return

	killall wpa_supplicant 2> /dev/null
	sleep 2

	sed "s/__rzaccount__/$WPA_USER/g;s/__rzpassword__/${WPA_PASSWORD/&/\\&}/g" /etc/wpa_supplicant.conf0 > /tmp/wpa_supplicant.conf
	wpa_supplicant -c /tmp/wpa_supplicant.conf -i$WLDEV -B

	echo
	echo -n "Suche Netz auf $WLDEV ..."

	dhclient $WLDEV || { echo "fehlgeschlagen"; echo "Beliebige Taste um fortzufahren."; read -n1; exit 1; }

	echo "OK"
}

function network_gui 
{
	dialog --backtitle "$BACKTITLE" --title "Netzwerk Probleme" --timeout 10 --yesno "Das Netzwerk (re)konfigurieren?" 0 0 || { reset -I; return; }
	./netconfig.sh
}

function wlan_gui 
{
	dialog --backtitle "$BACKTITLE" --title "WLAN Probleme" --timeout 10 --yesno "WLAN-Karte (re)konfigurieren?" 0 0 || { reset -I; return; }
	./wlanconf.sh
}

function pause
{
	echo "Beliebige Taste um fortzufahren."
	read -n1
}

function expert_gui
{
	EXP_CHOICE="1"
	dialog --backtitle "$BACKTITLE" --title "Experten-Menü?" --timeout 10 --yesno "Experten-Menü aufrufen?" 0 0 || { reset -I; return; }
	while true;
	do
		EXP_CHOICE=$(dialog --title "Status" --begin 2 5 --tailboxbg "$STATUSFILE" 4 74 --and-widget --title "Uhrzeit" --begin 29 5 --tailboxbg "$TIMEFILE" 4 35 --and-widget --default-item "$EXP_CHOICE" --stdout --nocancel --backtitle "$BACKTITLE" --title "erweiterte Problemlösung" --timeout 10 --menu "Auswahl" 0 35 5 "1" "automatische VPN-Einwahl" "2" "manuelle VPN-Einwahl" "3" "VPN beenden" "4" "manuelle wKIT/WPA-Einwahl" "5" "Zurück") || { reset -I; return; }

		case "$EXP_CHOICE"
		in
			1)
				vpnc_gui
			;;
			2)
				vpnc_gui manual
			;;
			3)
				killall vpnc
			;;
			4)
				wkit_gui
			;;
			5)
				return
			;;
		esac
	done
}

killall uhrzeit.sh 2> /dev/null
killall status.sh 2> /dev/null
./uhrzeit.sh &
./status.sh &

while true;
do
	CHOICE=$(dialog --title "Status" --begin 2 5 --tailboxbg "$STATUSFILE" 4 74 --and-widget --title "Uhrzeit" --begin 29 5 --tailboxbg "$TIMEFILE" 4 35 --and-widget --stdout --nocancel --backtitle "$BACKTITLE" --title "Problemlösung" --menu "Auswahl" 0 40 5 "1" "automatisches Verbinden" "2" "Netzwerk Probleme beheben" "3" "WLAN Probleme beheben" "4" "Experten Menü") || { CHOICE="-1"; reset -I; }

	case "$CHOICE"
	in
		1)
			./netsetup.sh -x
		;;
		2)
			network_gui
		;;
		3)
			wlan_gui
		;;
		4)
			expert_gui
		;;
	esac
done

