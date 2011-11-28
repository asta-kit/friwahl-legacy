#!/bin/bash

SRC=`dirname $0`

fwtmp=`mktemp -t -d fw.XXXXXXXXXX`
echo using $fwtmp as temporary directory

cp -rv "$SRC" "$fwtmp"
sudo chgrp -v postgres "$fwtmp" "$fwtmp/init.sh" "$fwtmp/FriCardWahl.sql"
chmod -v 750 "$fwtmp"  "$fwtmp/init.sh"
chmod -v 640 "$fwtmp/FriCardWahl.sql"

cd "$fwtmp"

./install.sh
sudo -u postgres ./init.sh
