#!/bin/bash

umount $(grep $(readlink -f work) /etc/mtab | cut '-d ' -f2 | sort -r)
rm -rf work

sed "s|%ustarepo%|$(readlink -f usta/repo)|g" usta/data/pacman.conf > /tmp/pacman.conf

echo Installiere Pakete...

mkarchiso -v -C /tmp/pacman.conf -p base create
mkarchiso -v -C /tmp/pacman.conf -p syslinux create

mkarchiso -v -C /tmp/pacman.conf -p "openssh unzip zip irssi ipw2100-fw ipw2200-fw wireless_tools zd1211-firmware broadcom-wl net-tools openssl perl vpnc iptables dhcp dhclient fping curl perl-www-curl expect netcfg pygobject vim wavemon dialog-usta splashy-full splashy-usta-theme" create

#fehlende pakete: madwifi madwifi-utils

echo Kopiere System Dateien...

cp -a usta/sysfiles/* work/root-image

mkdir -p work/iso/arch/boot/i686

echo Installiere ArchISO Hooks...
make -C archiso/archiso DESTDIR=$(readlink -f work/root-image) install

echo "Erstelle Wahl-Splash..."
usta/scripts/splashy.sh people.dat usta/data/wahlsplash.png work/root-image/usr/share/splashy/themes/usta/background.png

echo Erstelle InitCPIO...
mkarchroot -n -r "mkinitcpio -v -k /boot/vmlinuz-linux -g /boot/archiso.img" work/root-image

echo Installiere Kernel, InitCPIO und Bootloader...

mv work/root-image/boot/archiso.img work/iso/arch/boot/i686
mv work/root-image/boot/vmlinuz-linux work/iso/arch/boot/i686/vmlinuz

mkdir work/iso/arch/boot/syslinux

cp work/root-image/usr/lib/syslinux/menu.c32 work/iso/arch/boot/syslinux

mkdir work/iso/isolinux

cp work/root-image/usr/lib/syslinux/isolinux.bin work/iso/isolinux
cp work/root-image/usr/lib/syslinux/isohdpfx.bin work/iso/isolinux
cp usta/data/isolinux.cfg work/iso/isolinux/isolinux.cfg

cp usta/data/aitab work/iso/arch


