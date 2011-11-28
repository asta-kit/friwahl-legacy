#!/bin/bash

RED="\033[40;1;31m"
BLACK="\033[0m"

umount $(grep $(readlink -f work) /etc/mtab | cut '-d ' -f2 | sort -r)
rm -rf work

sed "s|%ustarepo%|$(readlink -f usta/repo)|g" usta/data/pacman.conf > /tmp/pacman.conf

echo -e $RED"Installiere Pakete..."$BLACK

mkarchiso -v -C /tmp/pacman.conf -p base create
mkarchiso -v -C /tmp/pacman.conf -p syslinux create

mkarchiso -v -C /tmp/pacman.conf -p "openssh unzip zip irssi ipw2100-fw ipw2200-fw wireless_tools zd1211-firmware broadcom-wl net-tools openssl perl vpnc iptables dhcp dhclient fping curl perl-www-curl expect netcfg pygobject vim wavemon dialog-usta splashy-full splashy-usta-theme" create

#fehlende pakete: madwifi madwifi-utils

echo -e $RED"Kopiere System Dateien..."$BLACK

cp -a usta/sysfiles/* work/root-image

mkdir -p work/iso/arch/boot/i686

echo -e $RED"Installiere ArchISO Hooks..."$BLACK
make -C archiso/archiso DESTDIR=$(readlink -f work/root-image) install

echo -e $RED"Erstelle Wahl-Splash..."$BLACK
usta/scripts/splashy.sh people.dat usta/data/wahlsplash.png work/root-image/usr/share/splashy/themes/usta/background.png

echo -e $RED"Erstelle InitCPIO..."$BLACK
mkarchroot -n -r "mkinitcpio -k /boot/vmlinuz-linux -g /boot/archiso.img" work/root-image

echo -e $RED"Installiere Kernel, InitCPIO und Bootloader..."$BLACK

mv work/root-image/boot/archiso.img work/iso/arch/boot/i686
mv work/root-image/boot/vmlinuz-linux work/iso/arch/boot/i686/vmlinuz

mkdir work/iso/arch/boot/syslinux

cp work/root-image/usr/lib/syslinux/menu.c32 work/iso/arch/boot/syslinux

mkdir work/iso/isolinux

cp work/root-image/usr/lib/syslinux/isolinux.bin work/iso/isolinux
cp work/root-image/usr/lib/syslinux/isohdpfx.bin work/iso/isolinux
cp usta/data/isolinux.cfg work/iso/isolinux/isolinux.cfg

cp usta/data/aitab work/iso/arch


