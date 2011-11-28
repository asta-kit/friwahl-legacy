#!/bin/sh
#
# Installation fuer das elektronische Waehlerverzeichnis (Server)
#
# (c) 2002-2004 Christoph Moench-Tegeder <moench-tegeder@rz.uni-karlsruhe.de>
#               Peter Schlaile <Peter.Schlaile@stud.uni-karlsruhe.de>
#               Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>
#
# Published under GPL
#

# Mist
if test "$BASH_VERSION" ; then
	set -o posix
	fi

urnenstart=10000
urnengruppe=10000
maxurnen=99

t=$0

while test $# -gt 0 ; do
	case $1 in
		-u)
			urnenstart=$2
			shift ; shift
			;;
		-g)
			urnengruppe=$2
			shift ; shift
			;;
		-h)
			echo "$t [-u uid-start] [-g gid]" >&2
			exit 1
			;;
		*)
			echo "Unbekannter Parameter $1" >&2
			exit 1
		esac
	done

sudo mkdir -v -m 755 -p /usr/local/FriCardWahl
sudo install -o root -g 0 -m 755 clearing.pl admin.pl liste.sh liste.pl /usr/local/FriCardWahl

sudo groupadd -g $urnengruppe urnen

sudo mkdir -p /home/urnen
mkdir -v -p uskel/.ssh
chmod -v 0750 uskel
chmod -v 0700 uskel/.ssh

>init.sql
chmod 640 init.sql
sudo chgrp postgres init.sql

i=0
while test $i -lt $maxurnen ; do
	i=$(($i+1))
	u=$(($i+$urnenstart))
	s=`printf "urne%02d" $i`
	d=/home/urnen/$s
	sudo useradd -d $d -m -k ./uskel -g urnen -s /bin/sh -c "Urne $i" -u $u $s
	echo "create user $s with nocreatedb nocreateuser in group g_urnen;" >> init.sql
	done

sudo -u postgres psql -c "create group g_urnen" template1
sudo -u postgres psql -c "create group g_ausschuss" template1

echo -n "Welche Accounts gehoeren zum Wahlausschuss? "
read admacc
for i in $admacc ; do
	sql="create user $i with createdb createuser in group g_ausschuss"
	sudo -u postgres psql -c "$sql" template1
	done
