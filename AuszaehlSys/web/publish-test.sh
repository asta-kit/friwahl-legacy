#!/bin/sh

cd $(dirname "$0")

WWWDIR=/www/UStA/Wahl/Ergebnisse-Test
TMPDIR=TMP2

umask 022
./build.sh $TMPDIR
rm -rf $WWWDIR &&
cp -r $TMPDIR $WWWDIR &&
publish wahl
