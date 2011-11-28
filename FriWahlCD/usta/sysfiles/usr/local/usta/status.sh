#!/bin/bash

#
# Copyright (C) 2008-2011 Mario Prausa
#
# $Id: status.sh 401 2011-01-09 18:33:05Z mariop $
#


STATUSFILE=/tmp/wahl-status
SERVER=$(cat /etc/friwahl/server)

while : ; do
	ANZ_NETWORKDEVICES=$(cat /proc/net/dev | gawk -F: '/eth.:|tr.:|wlan.:|ath.:/{print $1}' | wc -l)
	if [ -e /var/run/vpnc/pid ]
	then
		VPNC_STATUS="VPNC: läuft"
	else
		VPNC_STATUS="VPNC: läuft nicht"
	fi
	SERVER_STATUS="erreichbar"
	fping -q -r1 -t100 "$SERVER" &>/dev/null || SERVER_STATUS="nicht erreichbar"
	INTF=$(route | gawk "/*/ { print \$NF; exit }\\")
	IP=$(ifconfig $INTF | gawk -F"[ :]+" '/inet / { print $4 }')
	echo "$VPNC_STATUS, Server: $SERVER_STATUS, IP: $INTF/$IP" >> $STATUSFILE
	sleep 1
done

