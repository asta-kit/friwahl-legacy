#!/bin/bash

#
# Copyright (C) 2012 Mario Prausa
#

export TERM=linux

. /etc/profile

sleep 5

if [ ! -f /tmp/netsetup ]; then 
	logger "Running network setup"
	/usr/local/usta/netsetup.sh
	touch /tmp/netsetup
fi

/usr/local/usta/friwahl-run.sh

