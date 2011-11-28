#!/bin/sh

cd $(dirname "$0")

WWWDIR=/www/UStA/Wahl/Ergebnisse
TMPDIR=$(mktemp -d)

umask 022
./build.sh $TMPDIR
rm -rf $WWWDIR &&
cp -r $TMPDIR $WWWDIR &&
(
publish wahl;
chmod -R g+w $WWWDIR
)
