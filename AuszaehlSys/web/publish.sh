#!/bin/sh

cd $(dirname "$0")

#WWWDIR=/www/UStA/Wahl/Ergebnisse
WWWDIR=Ergebnisse-2012
TMPDIR=$(mktemp -d)

umask 022
./build.sh $TMPDIR
rm -rf $WWWDIR &&
cp -r $TMPDIR $WWWDIR
scp -r Ergebnisse-2012 pkirchhofer@login.usta.de:/www/UStA/Wahl
ssh bene@login.usta.de "/usr/usta/OpenBSD/bin/publish wahl"
# &&
#(
#publish wahl;
#chmod -R g+w $WWWDIR
#)
