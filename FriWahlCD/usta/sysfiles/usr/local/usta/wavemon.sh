#!/bin/bash

#
# Copyright (C) 2010-2011 Mario Prausa
#
# $Id: wavemon.sh 435 2011-01-13 23:21:52Z mariop $
#


while : ; do
	WLDEV=$(ip route | gawk "/*/ { print \$NF; exit }\\")

	if [ -d "/sys/class/net/$WLDEV/wireless" ]; then
		wavemon -i $WLDEV
	fi

	sleep 10
done

