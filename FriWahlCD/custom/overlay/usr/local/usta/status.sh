#!/bin/bash

#
# Copyright (C) 2008-2012 Mario Prausa
#


STATUSFILE=/tmp/wahl-status
SERVER=$(cat /etc/friwahl/server)

touch $STATUSFILE

while : ; do
	ANZ_NETWORKDEVICES=$(cat /proc/net/dev | gawk -F: '/eth.:|tr.:|wlan.:|ath.:/{print $1}' | wc -l)
	if [ -n "`pidof openvpn`" ]
	then
		VPN_STATUS="OpenVPN: läuft"
	else
		VPN_STATUS="OpenVPN: läuft nicht"
	fi
	
	SERVER_STATUS="erreichbar"
	if [ $(ip route | wc -l) -eq 0 ]; then
		SERVER_STATUS="nicht erreichbar"
		INTF=""
		IP="0.0.0.0"
	else 
		fping -q -r1 -t100 "$SERVER" &>/dev/null || SERVER_STATUS="nicht erreichbar"
		# extract the interface from ip's output. This relies on the device name being in the fifth position
		INTF=$(ip -o route show | grep "^default via" | cut -d" " -f 5)
		IP=$(ip addr show $INTF | gawk -F"[ :]+" '/inet / { print $3 }')
	fi

	echo "$VPN_STATUS, Server: $SERVER_STATUS, IP: $INTF - $IP" >> $STATUSFILE
	sleep 1
done

