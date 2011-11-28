#!/bin/bash

#
# $Id: irssi.sh 401 2011-01-09 18:33:05Z mariop $
#

chown -R irc:users /home/irc

export LANG=de_DE.utf8

sleep 5

ssh -L194:127.0.0.1:5557 -l `cat /etc/friwahl/user` -o "HostKeyAlias asta-wahl.asta.uni-karlsruhe.de" -i /etc/friwahl/key -N -f -n `cat /etc/friwahl/server`

su -c irssi -- irc

