#!/bin/bash

#
# $Id: friwahl-run.sh 401 2011-01-09 18:33:05Z mariop $
#

export PATH=/usr/local/usta/:$PATH
export LANG=de_DE.utf8

SERVER=`cat /etc/friwahl/server`

setterm -blank 0

echo "60" > /proc/sys/net/ipv4/tcp_keepalive_time
echo "10" > /proc/sys/net/ipv4/tcp_keepalive_intvl
echo "3"  > /proc/sys/net/ipv4/tcp_keepalive_probes
echo "0"  > /proc/sys/kernel/printk

cd /usr/local/usta

while ! ./friwahl-client.pl \
    $SERVER \
    `cat /etc/friwahl/user` \
    /etc/friwahl/key ; do
  if ! dialog \
      --backtitle 'FriWahl' \
      --title 'Verbindung fehlgeschlagen' \
      --yes-label 'Ja' --no-label 'Nein' \
      --yesno 'Programm neustarten?' -1 -1 ; then
      break
  fi
done
#chvt 4
halt

