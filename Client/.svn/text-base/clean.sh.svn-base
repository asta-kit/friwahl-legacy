#!/bin/bash

psql -f clean.sql wahl
dropdb wahl

i=0;
while [ $i -lt 99 ] ; do
	i=$(($i+1))
	echo remove user urne$(printf %02d $i) ...
	sudo userdel -r urne$(printf %02d $i)
	psql -c "drop user urne$(printf %02d $i);" template1
	done

sudo groupdel urnen

psql -c "drop user mariop;"  template1
psql -c "drop user juliangethmann;"  template1
psql -c "drop user andreasw;"  template1
psql -c "drop user heiko;"  template1

psql -c "drop group g_urnen;"  template1
psql -c "drop group g_ausschuss;"  template1

sudo rm -rf /usr/local/FriCardWahl
sudo rm -f masterkey.*
