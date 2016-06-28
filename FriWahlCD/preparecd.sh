#!/bin/bash

INFO="\033[42;1m"
BLACK="\033[0m"

LIVEFS=wahllive
ROOTFS=$LIVEFS/airootfs
OVERLAY=custom/overlay
DATA=custom/data

# TODO Cleanup build directory before working on it

cp -r /usr/share/archiso/configs/baseline/* $LIVEFS/
mkdir $LIVEFS/airootfs
cp -a $OVERLAY/* $ROOTFS/
cp $DATA/packages.* $LIVEFS/ 

sed "s|%customrepo%|$(readlink -f custom/repo)|g" custom/data/pacman.conf > $LIVEFS/pacman.conf

echo -e $INFO"Installiere Pakete..."$BLACK
mkdir $LIVEFS/out
pushd $LIVEFS > /dev/null 2>&1
./build.sh -v
popd > /dev/null 2>&1

#fehlende pakete: madwifi madwifi-utils

echo -e $INFO"Kopiere System Dateien..."$BLACK


# TODO move Post-Install Cleanup maybe to $ROOTFS/root/customize_airootfs.sh.
#rm -f $ROOTFS/etc/systemd/system/getty.target.wants/getty\@tty1.service
#chown -R 1000:100 $ROOTFS/home/irc
#echo -e $INFO"Generiere Locales..."$BLACK
#mkarchiso -r "locale-gen" run

#mkdir -p work/iso/arch/boot/x86_64
#echo -e $INFO"Installiere ArchISO Hooks..."$BLACK
#make -C archiso DESTDIR=$(readlink -f $ROOTFS) install-initcpio
#echo -e $INFO"Erstelle Wahl-Splash..."$BLACK
#cp $ROOTFS/etc/splash/custom/images/background.png /tmp
#custom/scripts/splash.sh people.dat /tmp/background.png $ROOTFS/etc/splash/custom/images/background.png
#rm /tmp/background.png

#echo -e $INFO"Erstelle InitCPIO..."$BLACK
#mkarchiso -r "mkinitcpio -k /boot/vmlinuz-linux -g /boot/archiso.img" run

#echo -e $INFO"Installiere Kernel, InitCPIO und Bootloader..."$BLACK

#mv $ROOTFS/boot/archiso.img work/iso/arch/boot/x86_64
#mv $ROOTFS/boot/vmlinuz-linux work/iso/arch/boot/x86_64/vmlinuz

#mkdir work/iso/arch/boot/syslinux

#mkdir work/iso/isolinux

#cp $ROOTFS/usr/lib/syslinux/bios/* work/iso/isolinux
#cp custom/data/isolinux.cfg work/iso/isolinux/isolinux.cfg

#cp custom/data/aitab work/iso/arch


