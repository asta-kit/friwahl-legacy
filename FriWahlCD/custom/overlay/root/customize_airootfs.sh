#!/bin/bash
set -e

INFO="\033[42;1m"
BLACK="\033[0m"

echo -e $INFO"Installation anpassen..."$BLACK
if [ -f "/etc/systemd/system/getty.target.wants/getty@tty1.service" ]; then
    rm -rf /etc/systemd/system/getty.target.wants/getty@tty1.service
fi
if [ -d "/etc/systemd/system/getty@tty1.service.d/" ]; then
    rm -rf /etc/systemd/system/getty@tty1.service.d/
fi
chown -R 1000:100 $ROOTFS/home/irc
locale-gen
