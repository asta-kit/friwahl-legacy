#!/bin/bash

DEST_DIR="$1"

if [ -z "$DEST_DIR" ] || [ "$#" != 1 ] ; then
    echo "usage: `basename $0` <DEST_DIR>"
    exit -1
fi


PHP=php4

fulldir() {
    pushd "$1" >/dev/null
    dirs -l +0
    popd >/dev/null
}

rm -rf "$DEST_DIR"   || exit -1
mkdir -p "$DEST_DIR" || exit -1

DEST_DIR=$(fulldir "$DEST_DIR")
SRC_DIR=$(fulldir $(dirname "$0"))
cd "$DEST_DIR"       || exit -1

for i in status.php wahlbeteiligung.php wahlen.php \
         stupa-fak.php rawdata.php ; do 
    echo "<NEWSECTION>\n" ;
    $PHP -c /etc/php4/apache -C -q $SRC_DIR/$i
done | 
$SRC_DIR/splitfiles.pl > index.lst

$PHP -c /etc/php4/apache -C -q $SRC_DIR/index.php |
$SRC_DIR/splitfiles.pl > /dev/null

perl -ne '/href='\''(.*\.html)/ && print "$1\n"' \
    < index.lst > all.cycle

perl -ne '/^FS[-_]/ && print' < all.cycle > fs.cycle
perl -ne '/^FS[-_]/ || print' < all.cycle > nofs.cycle

cp $SRC_DIR/wahl-logo.png $SRC_DIR/cycle.php .

rm index.lst
