#!/bin/bash

#
# Copyright (C) 2010-2011 Mario Prausa
#
# $Id: netsetup.sh 434 2011-01-13 23:18:52Z mariop $
#

. /etc/friwahl/rzaccount.sh

setterm -blank 0

sed "s/__rzaccount__/$RZACCOUNT@uni-karlsruhe.de/g;s/__rzpassword__/$RZPASSWORD/g" /etc/wpa_supplicant.conf0 > /tmp/wpa_supplicant.conf

for devdir in /sys/class/net/*; do
	dev=`echo $devdir | sed "s|/sys/class/net/||g"`
	if [ `cat $devdir/type` = "1" ]; then
		if [ -d "$devdir/wireless" ]; then
			wlans="$wlans $dev"
		else
			lans="$lans $dev"
		fi
	fi
done

killall vpnc 2> /dev/null
killall wpa_supplicant 2> /dev/null
killall dhclient 2> /dev/null

con=0

for dev in $lans; do
	up=0
	dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche über $dev eine Verbindung herzustellen.." 3 60
	
	if [ `cat /sys/class/net/$dev/operstate` != "down" ]; then
		up=1
	else
		ifconfig $dev up
		sleep 5
		if [ `cat /sys/class/net/$dev/operstate` != "down" ]; then
			up=1
		fi
	fi
	if [ $up = 1 ]; then
		dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche IP von $dev zu beziehen.." 3 60
		dhclient $dev
		ifconfig $dev | grep "inet .*\..*\..*\..*" > /dev/null
		if [ $? -eq 0 ]; then
			dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche IP von $dev zu beziehen.. Erfolg" 3 60			 
			con=1
			break
		else
			ifconfig $dev down
			dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche IP von $dev zu beziehen.. fehlgeschlagen" 3 60
		fi
	else
		ifconfig $dev down
		dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Kein Netzwerkkabel in $dev eingesteckt" 3 60
	fi
done

if [ $con = 0 ]; then
	for dev in $wlans; do
		dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche über $dev eine Verbindung herzustellen.." 3 60
		ifconfig $dev up
		sleep 5
		dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche über $dev mit wkit-802.1x zu verbinden.." 3 60
		wpa_supplicant -c /tmp/wpa_supplicant.conf -i$dev -B
		sleep 5
		dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche IP von $dev zu beziehen.." 3 60
		dhclient $dev
		ifconfig $dev | grep "inet .*\..*\..*\..*" > /dev/null
		if [ $? -eq 0 ]; then
			dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche IP von $dev zu beziehen.. Erfolg" 3 60
			con=1
			break
		else
			killall wpa_supplicant
			ifconfig $dev down
			dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche IP von $dev zu beziehen.. fehlgeschlagen" 3 60
		fi
	done
fi

if [ $con = 0 ]; then
	if [ "$1" == "-x" ]; then
		dialog --stdout --backtitle "$BACKTITLE" --title "Fehler" --msgbox "Verbindung fehlgeschlagen" 5 29
	else
		dialog --stdout --backtitle "$BACKTITLE" --title "Verbindung fehlgeschlagen" --yes-label "OK" --no-label "Herunterfahren" --yesno "Du kannst über Konsole 2 (Alt+F2) versuchen die Verbindung manuell herzustellen" 7 60

		if [ $? -eq 1 ]; then
			poweroff
		fi
	fi

	exit 1
fi

exit 0

