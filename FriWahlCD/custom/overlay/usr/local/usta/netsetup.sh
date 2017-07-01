#!/bin/bash

#
# Copyright (C) 2010-2012 Mario Prausa
#

. /etc/friwahl/rzaccount.sh

setterm -blank 0

sed "s|__rzaccount__|$RZACCOUNT@kit.edu|g;s|__rzpassword__|${RZPASSWORD/&/\\&}|g" /etc/wpa_supplicant.conf0 > /tmp/wpa_supplicant.conf

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

killall wpa_supplicant 2> /dev/null
killall dhclient 2> /dev/null

con=0

for dev in $lans; do
	up=0
	dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche über $dev eine Verbindung herzustellen.." 3 60
	logger "Connecting via $dev"

	if [ `cat /sys/class/net/$dev/operstate` != "down" ]; then
		up=1
		logger "Device $dev is up"
	else
		ip link set $dev up
		sleep 15
		if [ `cat /sys/class/net/$dev/operstate` != "down" ]; then
			up=1
			logger "Device $dev was down, is now up"
		fi
	fi
	if [ $up = 1 ]; then
		addr=0
		logger "Configuring device $dev"
		ip addr flush $dev
		ip route flush $dev
		dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche IP von $dev zu beziehen.." 3 60
		dhclient $dev || logger "Could not start dhclient for $dev"
		ip addr show $dev | grep "inet .*\..*\..*\..*" > /dev/null

		if [ $? -eq 0 ]; then
			dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche IP von $dev zu beziehen.. Erfolg" 3 60
			addr=1
			logger "Device $dev now has an IP address"
		else
			ip link set $dev down
			dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche IP von $dev zu beziehen.. fehlgeschlagen" 3 60
			logger "Could not get IP address for device $dev"
			continue
		fi
		if [ $addr = 1]; then
			ping captive-portal.scc.kit.edu -c 1 -W 5
			if [ $? -eq 0]; then
				curl -s --request POST 'https://captive-portal.scc.kit.edu/login' --data-urlencode "username=$RZACCOUNT" --data-urlencode "password=$RZPASSWORD" | grep -q "Anmeldung erfolgreich"
			else
				logger "Not in the LTA network"
			fi

			if [ $? -eq 0]; then
				con=1
				break
			else
					ip link set $dev down
					dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche am Captive Portal einzuloggen ... fehlgeschlagen" 3 60
					logger "Could register at captive portal"
			fi

		fi

	else
		ip link set $dev down
		dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Kein Netzwerkkabel in $dev eingesteckt" 3 60
	fi
done

if [ $con = 0 ]; then
	for dev in $wlans; do
		dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche über $dev eine Verbindung herzustellen.." 3 60
		ip link set $dev up
		sleep 5
		ip addr flush $dev
		ip route flush $dev
		dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche über $dev mit /vpn/web/belwue zu verbinden.." 3 60
		iwconfig "$dev" essid "vpn/web/belwue" || logger "Konnte keine Verbindung zu vpn/web/belwue herstellen"
		sleep 5
		dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche IP von $dev zu beziehen.." 3 60
		dhclient $dev || logger "Could not start dhclient for $dev"
		ip addr show $dev | grep "inet .*\..*\..*\..*" > /dev/null
		curl -s --request POST 'https://captive-portal.scc.kit.edu/login' --data-urlencode "username=$RZACCOUNT" --data-urlencode "password=$RZPASSWORD" | grep -q "Anmeldung erfolgreich"
		if [ $? -eq 0 ]; then
			con=1
			dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkverbindung wird hergestellt" --infobox "Versuche IP von $dev zu beziehen.. Erfolg" 3 60
			break
		else
			ip link set $dev down
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

