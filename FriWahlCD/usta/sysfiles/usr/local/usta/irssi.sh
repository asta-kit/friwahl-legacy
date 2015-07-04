#!/bin/bash

#
# Copyright (C) 2010-2012 Mario Prausa
#

export TERM=linux

IRCSERVER=fachschaft.physik.uni-karlsruhe.de

. /etc/profile

echo "Warte auf IRC-Server..."

while : ; do
	while [ $(ip route | wc -l) -eq 0 ]; do
		sleep 1
	done
	if fping -q -r1 -t100 "$IRCSERVER"; then 
		break
	fi
done

su -c irssi -- irc

