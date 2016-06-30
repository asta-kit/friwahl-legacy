#!/bin/bash

INFO="\033[42;1m"
BLACK="\033[0m"

echo -e $INFO"Installation anpassen..."$BLACK
rm -rf /etc/systemd/system/getty.target.wants/getty@tty1.service
chown -R 1000:100 $ROOTFS/home/irc
