#!/bin/bash

#
# $Id: irssi.sh 401 2011-01-09 18:33:05Z mariop $
#

chown -R irc:users /home/irc

export LANG=de_DE.utf8

sleep 5

su -c irssi -- irc

