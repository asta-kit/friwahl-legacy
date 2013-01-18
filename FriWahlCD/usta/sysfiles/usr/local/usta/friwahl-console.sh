#!/bin/bash

#
# Copyright (C) 2012 Mario Prausa
#

export TERM=linux

. /etc/profile

if [ ! -f /tmp/netsetup ]; then 
	/usr/local/usta/netsetup.sh
	touch /tmp/netsetup
fi

/usr/local/usta/friwahl-run.sh

