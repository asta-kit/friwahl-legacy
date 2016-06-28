#!/bin/bash

#
# Copyright (C) 2008 Mario Prausa
#
# $Id: uhrzeit.sh 401 2011-01-09 18:33:05Z mariop $
#


while : ; do 
	date '+%X        %a, %x' >> /tmp/timefile.tmp
	sleep 1
done

