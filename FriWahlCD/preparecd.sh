#!/bin/bash

RED="\033[40;1;31m"
BLACK="\033[0m"

rm -rf work

sed "s|%ustarepo%|$(readlink -f usta/repo)|g" usta/data/pacman.conf > /tmp/pacman.conf

echo -e $RED"Installiere Pakete..."$BLACK

mkarchiso -v -C /tmp/pacman.conf init
mkarchiso -v -C /tmp/pacman.conf -p base install
mkarchiso -v -C /tmp/pacman.conf -p syslinux install

mkarchiso -v -C /tmp/pacman.conf -p "openssh unzip zip irssi ipw2100-fw ipw2200-fw rfkill wireless_tools zd1211-firmware broadcom-wl b43-firmware wpa_supplicant net-tools openssl openvpn perl iptables dhcp dhclient fping curl perl-www-curl expect netcfg pygobject vim wavemon dialog-usta plymouth plymouth-theme-usta" install

#fehlende pakete: madwifi madwifi-utils

echo -e $RED"Kopiere System Dateien..."$BLACK

rm -f work/root-image/etc/systemd/system/getty.target.wants/getty\@tty1.service

cp -a usta/sysfiles/* work/root-image
chown -R 1000:100 work/root-image/home/irc

echo -e $RED"Generiere Locales..."$BLACK
mkarchiso -r "locale-gen" run

mkdir -p work/iso/arch/boot/i686

echo -e $RED"Installiere ArchISO Hooks..."$BLACK
make -C archiso DESTDIR=$(readlink -f work/root-image) install-initcpio

echo -e $RED"Erstelle Wahl-Splash..."$BLACK
cp work/root-image/etc/splash/usta/images/background.png /tmp
usta/scripts/splash.sh people.dat /tmp/background.png work/root-image/etc/splash/usta/images/background.png
rm /tmp/background.png

echo -e $RED"Erstelle InitCPIO..."$BLACK
mkarchiso -r "mkinitcpio -k /boot/vmlinuz-linux -g /boot/archiso.img" run

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


