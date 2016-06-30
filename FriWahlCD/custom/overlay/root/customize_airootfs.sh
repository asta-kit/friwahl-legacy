#!/bin/bash

INFO="\033[42;1m"
BLACK="\033[0m"

echo -e $INFO"Installation anpassen..."$BLACK
if [ -f /etc/systemd/system/getty.target.wants/getty@tty1.service ]
    rm -rf /etc/systemd/system/getty.target.wants/getty@tty1.service
fi
if [ -d airootfs/etc/systemd/system/getty@tty1.service.d/ ]
    rm -rf airootfs/etc/systemd/system/getty@tty1.service.d/
fi
chown -R 1000:100 $ROOTFS/home/irc
